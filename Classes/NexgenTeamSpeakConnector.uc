/*##################################################################################################
##
##  Nexgen Teamspeak 3 Connector version 2.01
##  Copyright (C) 2020 Patrick "Sp0ngeb0b" Peltzer
##
##  This program is free software; you can redistribute and/or modify
##  it under the terms of the Open Unreal Mod License version 1.1.
##
##  Contact: spongebobut@yahoo.com | www.unrealriders.eu
##
##################################################################################################*/
/*##################################################################################################
##  Changelog:
##
##  Version 2.01:
##  [Added]     - Teaspeak (teaspeak.de) server support
##
##  Version 2.00:
##  [Changed]   - Teamspeak query is now periodic instead of event driven
##  [Added]     - Non-UT TS clients are now also displayed and considered for joins/leaves messages
##              - Additional TS flags are displayed (country, talking, muted, microphone available)
##              - Single channel mode
##              - HUD overlay
##              - Tab caption displays connected client amount
##  [Fixed]     - Going into windowed mode when client was already in it caused going fullscreen
##  [Removed]   - Check connection button as it is no longer used
##
##  Version 1.00:
##  [Misc]:     - First public release.
##
##################################################################################################*/
class NexgenTeamSpeakConnector extends NexgenExtendedPlugin;

// Links
var NexgenTeamSpeakConnectorTCP TCPClient; // The TCP client

// Variables
var bool bMapChangeDetected;               // Whether a mapchange has been detected.
var bool bJustInstalled;                   // First time run?
var float fTimerPeriodInitial;             // Initial timer period at game start
var byte iModeInitial;                     // Initial iMode value when connected to TS server at game start

// The channel IDs
const DefaultChannelid    = 0;				     
const MixedChannelid      = 1;
const RedTeamChannelid    = 2;
const BlueTeamChannelid   = 3;
const SpecTeamChannelid   = 4;
const DisconnectChannelid = 5;

// TS Client data 
var byte   tsChanID  [64];
var string tsClientID[64];
var string tsName    [64];
var byte   tsFlags   [64];                 // Talkin +1, Muted +2, Hardware +4
var byte   tsTeam    [64];
var string tsCountry [64];
var byte   tsQueryDataIndex;

// Previous Data (for joins/leaves detection)
var byte   tsChanIDOld  [64];
var string tsClientIDOld[64];
var string tsNameOld    [64];
var byte   tsQueryDataIndexOld;

/***************************************************************************************************
 *
 *  SYSTEM FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the plugin. Note that if this function returns false the plugin will
 *                be destroyed and is not to be used anywhere.
 *  $RETURN       True if the initialization succeeded, false if it failed.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool initialize() {

  // Let super class initialize.
  if (!super.initialize()) {
    return false;
  }
  
  fTimerPeriodInitial = NexgenTeamSpeakConnectorConfig(xConf).fTimerPeriod;
  iModeInitial        = NexgenTeamSpeakConnectorConfig(xConf).iMode;

  if(NexgenTeamSpeakConnectorConfig(xConf).bEnabled && checkConfig()) {
    TCPClient = spawn(class'NexgenTeamSpeakConnectorTCP', self);
    SetTimer(NexgenTeamSpeakConnectorConfig(xConf).fTimerPeriod, true);
  }
  
  return true;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer used for periodic TS server querying.
 *
 **************************************************************************************************/
function Timer() {

  if(TCPClient != none) {
    TCPClient.queryChannel(); 
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a client has finished its initialisation process. During this
 *                process things such as the remote control window are created. So only after the
 *                client is fully initialized all functions can be safely called.
 *  $PARAM        client  The client that has finished initializing.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function clientInitialized(NexgenClient client) {
	local NexgenExtendedClientController xClient;

	// Get client controller.
	xClient = getXClient(client);

	// Initialize shared data for the client.
	if (xClient != none && client.hasRight(client.R_ServerAdmin)) {
		dataSyncMgr.initRemoteClient(xClient);
	}
	
	// Sync bEnabled and iMode with new client
	xClient.sendStr(NexgenTeamSpeakConnectorClient(xClient).CMD_TS_PREFIX @ NexgenTeamSpeakConnectorClient(xClient).CMD_TS_BENABLED
                    @ (NexgenTeamSpeakConnectorConfig(xConf).bEnabled && TCPClient != none && TCPClient.IsConnected()) @ fTimerPeriodInitial @ iModeInitial);

  // Sync Channel names with new client
  if(NexgenTeamSpeakConnectorConfig(xConf).bEnabled && TCPClient != none && TCPClient.IsConnected())  {
    xClient.sendStr(NexgenTeamSpeakConnectorClient(xClient).CMD_TS_PREFIX @ NexgenTeamSpeakConnectorClient(xClient).CMD_TS_CHANNELNAMES 
                    @ formatCmdArgFixed(NexgenTeamSpeakConnectorConfig(xConf).TSadress) @ formatCmdArgFixed(NexgenTeamSpeakConnectorConfig(xConf).TSport)
                    @ formatCmdArgFixed(ChannelName(DefaultChannelid)) @ formatCmdArgFixed(ChannelName(MixedChannelid)) @ formatCmdArgFixed(ChannelName(RedTeamChannelid))
                    @ formatCmdArgFixed(ChannelName(BlueTeamChannelid)) @ formatCmdArgFixed(ChannelName(SpecTeamChannelid)) @ formatCmdArgFixed(ChannelName(DisconnectChannelid)));
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles a potential command message.
 *  $PARAM        sender  PlayerPawn that has send the message in question.
 *  $PARAM        msg     Message send by the player, which could be a command.
 *  $REQUIRE      sender != none
 *  $RETURN       True if the specified message is a command, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool handleMsgCommand(PlayerPawn sender, string msg) {
	local string cmd;
	local bool bIsCommand;
	local NexgenTeamSpeakConnectorClient xClient;
	
	if(!NexgenTeamSpeakConnectorConfig(xConf).bEnabled) return false;

	cmd = class'NexgenUtil'.static.trim(msg);
	bIsCommand = true;
	
	switch (cmd) {
		case "!ts":
		case "!teamspeak":
			xClient = NexgenTeamSpeakConnectorClient(getXClient(sender));
			if (xClient != none) {
				xClient.openTSPanel();
			}
    break;
		case "!tsjoin":
		case "!tsenter":
			xClient = NexgenTeamSpeakConnectorClient(getXClient(sender));
			if (xClient != none) {
				xClient.ConnectToTS();
			}
		break;
		case "!tschannel":
		case "!tsswitch":
    	xClient = NexgenTeamSpeakConnectorClient(getXClient(sender));
			if (xClient != none && NexgenTeamSpeakConnectorConfig(xConf).iMode != 0) {
				xClient.ChangeChannel(true);
			}
    break;
    case "!tsdisconnect":
    case "!tsleave":
    xClient = NexgenTeamSpeakConnectorClient(getXClient(sender));
		if (xClient != none) {
			xClient.Disconnect();
		}
		// Not a command.
		default: bIsCommand = false;
	}

	return bIsCommand;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the plugin requires the to shared data containers to be created. These
 *                may only be created / added to the shared data synchronization manager inside this
 *                function. Once created they may not be destroyed until the current map unloads.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function createSharedDataContainers() {
  dataSyncMgr.addDataContainer(class'NexgenTeamSpeakConnectorConfigDC');
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called whenever a player has joined the game (after its login has been accepted).
 *  $PARAM        client  The player that has joined the game.
 *  $REQUIRE      client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function playerLeft(NexgenClient client) {
	local NexgenTeamSpeakConnectorClient xClient;
	
	if(!NexgenTeamSpeakConnectorConfig(xConf).bEnabled) return;

  xClient = NexgenTeamSpeakConnectorClient(getXClient(client));
	if (xClient != none && TCPClient != none && NexgenTeamSpeakConnectorConfig(xConf).iMode != 0) {
		xClient.ChangeChannel(false, true);
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Deals with a client that has switched to another team.
 *  $PARAM        client  The client that has changed team.
 *  $REQUIRE      client.team != client.player.playerReplicationInfo.team
 *
 **************************************************************************************************/
function playerTeamChanged(NexgenClient client) {
	local NexgenTeamSpeakConnectorClient xClient;
	
	if(!NexgenTeamSpeakConnectorConfig(xConf).bEnabled || NexgenTeamSpeakConnectorConfig(xConf).iMode == 0) return;

  xClient = NexgenTeamSpeakConnectorClient(getXClient(client));

 	if (xClient != none && TCPClient != none) {
		xClient.ChangeChannel(false, false, true);
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the game executes its next 'game' tick.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	if (NexgenTeamSpeakConnectorConfig(xConf).bEnabled && !bMapChangeDetected && level.nextURL != "") {
    bMapChangeDetected = True;
		DisconnectClients();
	}
}

/***************************************************************************************************
 *
 *  MISC FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Moves all TS clients to the Disconnected Players channel.
 *
 **************************************************************************************************/
function DisconnectClients() {
  local NexgenClient c;
  local NexgenTeamSpeakConnectorClient xClient;
  
  if(!NexgenTeamSpeakConnectorConfig(xConf).bEnabled || NexgenTeamSpeakConnectorConfig(xConf).iMode == 0) return;

  for(c=control.clientList;c!=none;c=c.nextClient) {
    xClient = NexgenTeamSpeakConnectorClient(getXClient(c));

    if(xClient != none && xClient.bConnected) {
      xClient.ChangeChannel(false, true);
    }
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *  $PARAM        author           Object that was responsible for the change.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index, optional Object author) {
	local NexgenClient client;

	// Log admin actions.
	if (author != none && (author.isA('NexgenClient') || author.isA('NexgenClientController')) &&
      container.containerID ~= class'NexgenTeamSpeakConnectorConfigDC'.default.containerID) {

		// Get client.
		if (author.isA('NexgenClientController')) {
			client = NexgenClientController(author).client;
		} else {
			client = NexgenClient(author);
		}
		// Log action.
		control.logAdminAction(client, "<C07>%1 has set %2.%3 to \"%4\".", client.playerName,
			                     string(xConf.class), varName, container.getString(varName),
			                     client.player.playerReplicationInfo, true, true);
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Validates the current config.
 *  $RETURN       True if the config is valid, false if not.
 *
 **************************************************************************************************/
function bool checkConfig() {

  if(  NexgenTeamSpeakConnectorConfig(xConf).fTimerPeriod < 0.2 || NexgenTeamSpeakConnectorConfig(xConf).fTimerPeriod > 5.0 ||
      (NexgenTeamSpeakConnectorConfig(xConf).iMode != 0 && NexgenTeamSpeakConnectorConfig(xConf).iMode != 1) ||
       NexgenTeamSpeakConnectorConfig(xConf).TSadress == "" ||
       NexgenTeamSpeakConnectorConfig(xConf).TSport < 0 || NexgenTeamSpeakConnectorConfig(xConf).TSport > 66535 ||
       NexgenTeamSpeakConnectorConfig(xConf).TSqueryport < 0 || NexgenTeamSpeakConnectorConfig(xConf).TSqueryport > 66535 ||
       NexgenTeamSpeakConnectorConfig(xConf).TSusername == "" || NexgenTeamSpeakConnectorConfig(xConf).TSuserpassword == "" ||
      (NexgenTeamSpeakConnectorConfig(xConf).iMode == 0 && NexgenTeamSpeakConnectorConfig(xConf).DefaultChannel == "") || 
      (NexgenTeamSpeakConnectorConfig(xConf).iMode == 1 && 
       (NexgenTeamSpeakConnectorConfig(xConf).MixedChannel == "" || NexgenTeamSpeakConnectorConfig(xConf).RedChannel == "" ||
        NexgenTeamSpeakConnectorConfig(xConf).BlueChannel == "" && Level.Game.GameReplicationInfo.bTeamGame ||
        NexgenTeamSpeakConnectorConfig(xConf).SpecChannel == "" || NexgenTeamSpeakConnectorConfig(xConf).DisconnectedChannel == ""))) {
    if(!bJustInstalled) control.nscLog("[NexgenTeamSpeakConnector] [ERROR] Invalid configuration found. Not starting.");
    return false;
  }

  return true;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Function to give the appropriate channel name.
 *
 **************************************************************************************************/
function string ChannelName(int id) {
  switch(id) {
    case DefaultChannelid:    return NexgenTeamSpeakConnectorConfig(xConf).DefaultChannel;
    case MixedChannelid:      return NexgenTeamSpeakConnectorConfig(xConf).MixedChannel;
    case RedTeamChannelid:    return NexgenTeamSpeakConnectorConfig(xConf).redChannel;
    case BlueTeamChannelid:   return NexgenTeamSpeakConnectorConfig(xConf).blueChannel;
    case SpecTeamChannelid:   return NexgenTeamSpeakConnectorConfig(xConf).SpecChannel;
    case DisconnectChannelid: return NexgenTeamSpeakConnectorConfig(xConf).DisconnectedChannel;
    default: return "";
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the TCP client updated the query data. 
 *                Announce player joins/leaves, check player connection status
 *
 **************************************************************************************************/
function queryDataReceived() {
  local NexgenClient c;
  local NexgenTeamSpeakConnectorClient xClient;
  local int i,j;
  local byte oldFound[64], newFound[64];
  local bool bFound;
  
  for(i=0; i<tsQueryDataIndexOld; i++) {
    for(j=0; j<tsQueryDataIndex; j++) {
      if(tsNameOld[i] == tsName[j] && tsChanIDOld[i] == tsChanID[j]) {
        oldFound[i] = 1;
        newFound[j] = 1;
      }
    }
  }
  
  for(c=control.clientList;c!=none;c=c.nextClient) {
    xClient = NexgenTeamSpeakConnectorClient(getXClient(c));
    
    // Notify about client leaves/joins
    if(xClient.bConnected && !xClient.bChangingChannel && xClient.bNotifyChannelChanges && (iModeInitial == 0 || (Level.TimeSeconds-xClient.connectionTime) > 2.00) && !bMapChangeDetected) { 
      for(i=0; i<tsQueryDataIndexOld; i++) if(oldFound[i] == 0 && tsChanIDOld[i] == xClient.currChannel && tsNameOld[i] != xClient.TSNick) xClient.client.showMsg("<C04>"$tsNameOld[i]$" left your channel.");
      for(i=0; i<tsQueryDataIndex; i++)    if(newFound[i] == 0 && tsChanID[i] == xClient.currChannel && tsName[i] != xClient.TSNick)       xClient.client.showMsg("<C04>"$tsName[i]$" joined your channel.");
    }
    
    // Find player 
    bFound = false;
    for(i=0; i<tsQueryDataIndex; i++) {
      if(tsName[i] == xClient.TSNick) {
        if(xClient.bClientSettingsAvailable && !xClient.bConnected) { 
          xClient.TSclid = int(tsClientID[i]);
          xClient.PlayerFound();
        }
        bFound = true;
        tsTeam[i] = c.team;
        break;
      }
    }
    if(!bFound && (xClient.bCheckingInitialTSStatus || xClient.bConnected)) xClient.PlayerNotFound();
   
    if(tsQueryDataIndex != xClient.clientAmount) xClient.sendClientAmount(tsQueryDataIndex);
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Moves the old data to another array to keep track of joins/leaves and resets 
 *                working array.
 *
 **************************************************************************************************/
function resetQueryData() {
  local int i;
  
  for(i=0; i<tsQueryDataIndexOld; i++) {
    tsChanIDOld[i]   = 255;
    tsClientIDOld[i] = "";
    tsNameOld[i]     = "";
  }
  
  for(i=0; i<tsQueryDataIndex; i++) {
    tsChanIDOld[i]   = tsChanID[i];
    tsClientIDOld[i] = tsClientID[i];
    tsNameOld[i]     = tsName[i];
    
    tsChanID[i]   = 255;
    tsClientID[i] = "";
    tsName[i]     = "";
    tsFlags[i]    = 255;
    tsTeam[i]     = 128;
    tsCountry[i]  = "";
  }
  tsQueryDataIndexOld = tsQueryDataIndex;
  tsQueryDataIndex = 0;
}

/***************************************************************************************************
 *
 *  Below are fixed functions for the Empty String TCP bug. Check out this article to read more
 *  about it: http://www.unrealadmin.org/forums/showthread.php?t=31280
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixed serverside set() function of NexgenSharedDataSyncManager. Uses correct
 *                formatting.
 *
 **************************************************************************************************/
function setFixed(string dataContainerID, string varName, coerce string value, optional int index, optional Object author) {
	local NexgenSharedDataContainer dataContainer;
	local NexgenClient client;
	local NexgenExtendedClientController xClient;
	local string oldValue;
	local string newValue;

    // Get the data container.
	dataContainer = dataSyncMgr.getDataContainer(dataContainerID);
	if (dataContainer == none) return;

	oldValue = dataContainer.getString(varName, index);
	dataContainer.set(varName, value, index);
	newValue = dataContainer.getString(varName, index);

	// Notify clients if variable has changed.
	if (newValue != oldValue) {
		for (client = control.clientList; client != none; client = client.nextClient) {
			xClient = getXClient(client);
			if (xClient != none && xClient.bInitialSyncComplete && dataContainer.mayRead(xClient, varName)) {
				if (dataContainer.isArray(varName)) {
					xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_UPDATE_VAR
						              @ static.formatCmdArgFixed(dataContainerID)
						              @ static.formatCmdArgFixed(varName)
						              @ index
						              @ static.formatCmdArgFixed(newValue));
				} else {
					xClient.sendStr(xClient.CMD_SYNC_PREFIX @ xClient.CMD_UPDATE_VAR
						              @ static.formatCmdArgFixed(dataContainerID)
						              @ static.formatCmdArgFixed(varName)
						              @ static.formatCmdArgFixed(newValue));
				}
			}
		}
	}

	// Also notify the server side controller of this event.
	if (newValue != oldValue) {
		varChanged(dataContainer, varName, index, author);
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Corrected version of the static formatCmdArg function in NexgenUtil. Empty strings
 *                are formated correctly now (original source of all trouble).
 *
 **************************************************************************************************/
static function string formatCmdArgFixed(coerce string arg) {
	local string result;

	result = arg;

	// Escape argument if necessary.
	if (result == "") {
		result = "\"\"";                      // Fix (originally, arg was assigned instead of result -_-)
	} else {
		result = class'NexgenUtil'.static.replace(result, "\\", "\\\\");
		result = class'NexgenUtil'.static.replace(result, "\"", "\\\"");
		result = class'NexgenUtil'.static.replace(result, chr(0x09), "\\t");
		result = class'NexgenUtil'.static.replace(result, chr(0x0A), "\\n");
		result = class'NexgenUtil'.static.replace(result, chr(0x0D), "\\r");

		if (instr(arg, " ") > 0) {
			result = "\"" $ result $ "\"";
		}
	}

	// Return result.
	return result;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     versionNum=201
     extConfigClass=Class'NexgenTeamSpeakConnectorConfigExt'
     sysConfigClass=Class'NexgenTeamSpeakConnectorConfigSys'
     clientControllerClass=Class'NexgenTeamSpeakConnectorClient'
     pluginName="Nexgen TeamSpeak 3 Connector"
     pluginAuthor="Sp0ngeb0b"
     pluginVersion="2.01"
}