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
class NexgenTeamSpeakConnectorClient extends NexgenExtendedClientController;

// Both sided connection variables
var string TSNick;                      // The client's nickname on the TS server.           
var bool bConnecting;                   // Is the client trying to connect?                  
var bool bConnected;                    // Is the client successfully connected?             
var byte clientAmount;                  // Amount of clients on TS server (displayed in tab).

// Server side connection variables
var int TSclid;                         // This client's unique ID on the TS server.
var bool bClientSettingsAvailable;      // Whether this client's TS settings are available.
var int numTries;                       // Connection tries.
var bool bCheckingInitialTSStatus;      // Whether we are searching for the player the first time. If he's not found, auto connect him.
var bool bChangingChannel;              // Whether the client is changing channels.
var int currChannel;                    // ID of the current channel.
var int newChannel;                     // ID of the new channel.

// Client side connection variables
var string currChannelString;           // Name of the current channel.                      
var float lastQueryTime;                // Control variable to not overflow the connection.

// Misc variables
var float connectionTime;               // Level.TimeSeconds when the client connected to TS.
var float lastActionTime;               // TimeSeconds of the last input by the client.
var int   nsvTries;                     // Attempt count of finding NSVHUD.
var float NSVHUDFound;                  // TimeSeconds when the NSVHUD was found.

// Client side server settings
var bool bEnabled;                      // Whether the Plugin is enabled.
var float fTimerPeriod;                 // Server TS query period.
var byte iMode;                         // Which Panel is to be displayed.
var string TSadress;                    // TS adress to display.
var int    TSport;                      // TS port to display.
var string DefaultChannelname;          // Name of the Default Channel.
var string MixedChannelname;            // Name of the Mixed Channel.
var string RedChannelname;              // Name of the Red Team Channel.
var string BlueChannelname;             // Name of the Blue Team Channel.
var string SpecChannelname;             // Name of the Spectator Channel.
var string DisconnectedChannelname;     // Name of the Disconnected Players Channel.

// Channel query information (client side).
// Buffer.
var byte   bufferChannel[64];
var string bufferNames  [64];
var byte   bufferFlags  [64];
var byte   bufferTeam   [64];
var string bufferCountry[64];
var byte   bufferIndex;
// Last received channel data.
var string mixedChannelNames  [64];
var byte   mixedChannelFlags  [64];
var byte   mixedChannelTeam   [64];
var string mixedChannelCountry[64];
var byte   mixedChannelIndex;
var string redChannelNames    [16];
var byte   redChannelTeam     [16];
var byte   redChannelFlags    [16];
var string redChannelCountry  [16];
var byte   redChannelIndex;
var string blueChannelNames   [16];
var byte   blueChannelTeam    [16];
var byte   blueChannelFlags   [16];
var string blueChannelCountry [16];
var byte   blueChannelIndex;
var string specChannelNames   [16];
var byte   specChannelTeam    [16];
var byte   specChannelFlags   [16];
var string specChannelCountry [16];
var byte   specChannelIndex;

// Links (client-side)
var NexgenTeamSpeakConnectorPanel TSPanel; // The GUI.
var NexgenTeamSpeakConnectorHUD xHUD;      // The HUD overlay.
var Mutator NSVHud;                        // Nexgen Stats Viewer HUD (if present).

// Client side settings.
const SSTR_AutoTSConnect         = "bAutoTSConnect";
const SSTR_FavTSChannel          = "iFavTSChannel";
const SSTR_autoToggleScreen      = "bAutoToggleScreen";
const SSTR_TSNick                = "sTSNick";
const SSTR_bNotifyChannelChanges = "bNotifyChannelChanges";
const SSTR_TSHUDType             = "iTSHUDType";

// Server-side synced client config settings
var bool autoTSConnect;
var int  favTSChannel;
var string savedTSNick;
var bool bNotifyChannelChanges;

// Commands
const CMD_TS_PREFIX              = "TS";
const CMD_TS_BENABLED            = "BE";
const CMD_TS_CHANNELNAMES        = "CN";
const CMD_TS_CLIENTSETTINGS      = "CS";
const CMD_TS_CHANNELCLIENTS      = "CC";
const CMD_TS_CHANNELCLIENTS_DONE = "CD";
const CMD_TS_SERVERVARS          = "SV";
const CMD_TS_SERVERVARS_SYNCED   = "SY";
const CMD_TS_CLIENT_AMOUNT       = "CA";

// Other constants
const connectingTimer    = 0.5;         // TS server connection detector timer. (server side used)
const connectingTimeout  = 10.0;        // Timeout for the connection detector. 
const MinCommandWaitTime = 1.00;        // Flood-protection wait time between client-actions.
const maxNSVTries        = 50;          // Ticks until the NSVHud must be located before giving up.
const queryTimeout       = 1.0;         // Timeout until a query result must be available.

/***************************************************************************************************
 *
 *  $DESCRIPTION  Replication block.
 *
 **************************************************************************************************/
replication {

  reliable if (role == ROLE_Authority) // Replicate to client...
		// Functions.
		Connect, ToggleFullScreen, openTSPanel, saveTSNick;
		
  reliable if (role != ROLE_Authority) // Replicate to server...
		// Functions.
		getTSclients, wantsConnect, wantsDisconnect, wantsSwitch;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Time critical event detection loop. Locates the NSVHUD if present.
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function tick(float deltaTime) {
  local Mutator m;
  
  super.tick(deltaTime);

  if (role != ROLE_Authority && NSVHud == none && nsvTries < maxNSVTries) {
    // Locate NSV
    forEach AllActors(class'Mutator', m) {
      if(InStr(CAPS(string(m.class)), "NSVHUD") != -1) { 
        NSVHud = m;
        NSVHUDFound = Level.TimeSeconds;
        return;
      }
    }   
    nsvTries++;
  }
}

/***************************************************************************************************
 *
 *  GAME FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the initial synchronization of the given shared data container is
 *                done. After this has happend the client may query its variables and receive valid
 *                results (assuming the client is allowed to read those variables).
 *  $PARAM        container  The shared data container that has become available for use.
 *  $REQUIRE      container != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function dataContainerAvailable(NexgenSharedDataContainer container) {
  if (container.containerID == class'NexgenTeamSpeakConnectorConfigDC'.default.containerID) {
    if (client.hasRight(client.R_ServerAdmin)) {
	    client.addPluginConfigPanel(class'NexgenTeamSpeakConnectorConfigPanel');
	  }
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the client has finished its initialisation process. This function is
 *                called on the client in the clientInitialize() function and is replicated to the
 *                server.
 *
 **************************************************************************************************/
simulated function clientInitialized() {
  local string Nick;

  if (client.hasRight(client.R_ServerAdmin)) super.clientInitialized();
  
  Nick = class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(client.gc.get(SSTR_TSNick, ""));

  sendStr(CMD_TS_PREFIX @ CMD_TS_CLIENTSETTINGS @ client.gc.get(SSTR_AutoTSConnect, "false") @
          client.gc.get(SSTR_FavTSChannel, "0") @ Nick @ client.gc.get(SSTR_bNotifyChannelChanges, "true") @ true);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Timer used for the initial status determination and for the connection detection
 *                (Server side) and for querying the TS data (Client side).
 *
 **************************************************************************************************/
simulated function Timer() {
  
  // Client side actions (querying)
  if (role != ROLE_Authority) {
    // Query server if desired
    if((TSPanel != none && TSPanel.bWindowVisible && client.mainWindow.bWindowVisible) ||
       (xHUD != none && xHUD.bEnabled)) {
      queryChannels();
    }
  } else {
  // Serverside intitial TS connection timer
    if(bConnecting) {
      if(numTries*connectingTimer > connectingTimeout ) {
        client.showMsg("<C00>Connection failed!");
        ToggleFullScreen(true);
        numTries=0;
        setTimer(0.0, false);
        bConnecting = False;
        SyncVariables();
        return;
      }
    }
    numTries++;
  }
}

/***************************************************************************************************
 *
 *  TEAMSPEAK FUNCTIONS
 *
 **************************************************************************************************/

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside function for connecting the client to the TS server.
 *
 **************************************************************************************************/
function ConnectToTS() {
  local string serverAdress, serverpassword, defaultchannelpw, url;
  local int serverPort, defaultchannelID;

  if(!NexgenTeamSpeakConnectorConfig(xControl.xConf).bEnabled ||
     NexgenTeamSpeakConnector(xControl).TCPClient == none ||
     !NexgenTeamSpeakConnector(xControl).TCPClient.IsConnected()) return;
     
  if(bConnecting) {
    client.showMsg("<C00>You are already connecting!");
    return;
  } else if(bConnected) {
    client.showMsg("<C00>You are already connected!");
    return;
  } else if(bCheckingInitialTSStatus || !bClientSettingsAvailable) {
    client.showMsg("<C00>You are not yet initialized!");
    return;
  }

  TSNick = getSaveTSName(client.playerName);

  serverAdress     = NexgenTeamSpeakConnectorConfig(xControl.xConf).TSadress;
  serverPort       = NexgenTeamSpeakConnectorConfig(xControl.xConf).TSport;
  serverpassword   = NexgenTeamSpeakConnectorConfig(xControl.xConf).TSpassword;
  defaultchannelID = NexgenTeamSpeakConnector(xControl).TCPClient.channelIDs[NexgenTeamSpeakConnector(xControl).DefaultChannelid];
  defaultchannelpw = NexgenTeamSpeakConnectorConfig(xControl.xConf).DefaultChannelpw;

  if(serverAdress != "" && serverPort > 0 && serverPort <= 65535) {
    lastActionTime = level.TimeSeconds;
    client.showMsg("<C04>Connecting to Teamspeak 3 server...");
    url = "ts3server://"$serverAdress$":"$serverPort$"?nickname="$TSNick;
    if(serverpassword != "") url = url$"&password="$serverpassword;
    if(defaultchannelID > 0) {
      url = url$"&cid="$defaultchannelID;
      if(defaultchannelpw != "") url = url$"&channelpassword="$defaultchannelpw;
    }
    ToggleFullScreen(false);
    Connect(url);
    saveTSNick(TSNick);
    bConnecting = True;
    SyncVariables();
    setTimer(connectingTimer, true);
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside function to Disconnect the client from the TS server.
 *
 **************************************************************************************************/
function Disconnect() {

  if(!NexgenTeamSpeakConnectorConfig(xControl.xConf).bEnabled ||
     NexgenTeamSpeakConnector(xControl).TCPClient == none ||
     !NexgenTeamSpeakConnector(xControl).TCPClient.IsConnected() || !bConnected) return;

  lastActionTime = level.TimeSeconds;
  NexgenTeamSpeakConnector(xControl).TCPClient.Disconnect(self);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside function to move the player to a different TS channel.
 *  $PARAM (optional) bForceChange  Change the player's Channel to the exact opposite.
 *  $PARAM (optional) bPlayerLeft   Whether to move the player to the Disconnected Players chanel.
 *  $PARAM (optional) bTeamChanged  Player changed his team.
 *
 **************************************************************************************************/
function ChangeChannel(optional bool bForceChange, optional bool bPlayerLeft, optional bool bTeamChanged) {

  if(!NexgenTeamSpeakConnectorConfig(xControl.xConf).bEnabled ||
     NexgenTeamSpeakConnector(xControl).TCPClient == none ||
     !NexgenTeamSpeakConnector(xControl).TCPClient.IsConnected() || bChangingChannel ||
     NexgenTeamSpeakConnector(xControl).iModeInitial == 0) return;

  if(!bConnected) {
    client.showMsg("<C00>You have to be connected in order to change the channel!");
    return;
  }
  
  if(bForceChange && level.TimeSeconds - lastActionTime < MinCommandWaitTime) {
    client.showMsg("<C00>Wait a moment before performing another action!");
    return;
  }

  if(bPlayerLeft) newChannel = NexgenTeamSpeakConnector(xControl).DisconnectChannelid;
  else if(bTeamChanged && Level.Game.GameReplicationInfo.bTeamGame) {
    if(currChannel != NexgenTeamSpeakConnector(xControl).MixedChannelid) {
      newChannel = findTeamChannel();
    }
  } else if(bForceChange && currChannel != -1) {
    if(currChannel == NexgenTeamSpeakConnector(xControl).MixedChannelid) {
      newChannel = findTeamChannel();
    } else newChannel = NexgenTeamSpeakConnector(xControl).MixedChannelid;
  } else if(favTSChannel == 0 ) newChannel = NexgenTeamSpeakConnector(xControl).MixedChannelid;
  else newChannel = findTeamChannel();

  if(currChannel != -1 && currChannel == newChannel) {
    return;
  }
  
  bChangingChannel = True;
  lastActionTime = level.TimeSeconds;
  NexgenTeamSpeakConnector(xControl).TCPClient.ChangeChannel(self, newChannel);
}

/***************************************************************************************************
 *
 *  TEAMSPEAK CALLS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside call when a player has been detected on the TS server.
 *
 **************************************************************************************************/
function PlayerFound() {
  Connected();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside call when a player was not found on the TS server.
 *
 **************************************************************************************************/
function PlayerNotFound() {
  if(bCheckingInitialTSStatus) {
    bCheckingInitialTSStatus = False;
    if(autoTSConnect) ConnectToTS();
  } else if(bConnected) {
    Disconnected();
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside call when the connection to the TS server has been registered.
 *
 **************************************************************************************************/
function Connected() {
    if(bConnecting) {
      setTimer(0.0, false);
      numTries = 0;
      ToggleFullScreen(true);
      client.showMsg("<C02>Successfully connected to this gameserver's Teamspeak 3 server!");
    } else client.showMsg("<C02>You are connected to this gameserver's Teamspeak 3 server.");
    bConnecting = False;
    bCheckingInitialTSStatus = False;
    bConnected = True;
    connectionTime = Level.TimeSeconds;
    if(NexgenTeamSpeakConnector(xControl).iModeInitial == 0) currChannel = 1;
    SyncVariables();
    ChangeChannel();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called on the server when the client was successfully disconnected.
 *
 **************************************************************************************************/
function Disconnected() {
  if(!bConnected) return;

  if(client != none) client.showMsg("<C02>Disconnected from TS server.");
  bConnected  = False;
  currChannel = -1;
  newChannel  = -1;
  TSclid = -1;
  SyncVariables();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside call when the channel switch of the player was Successful.
 *
 **************************************************************************************************/
function SwitchSuccessful() {
  client.showMsg("<C02>Channel switched.");
  currChannel = newChannel;
  bChangingChannel = False;
  client.showMsg("<C04>Current channel:"@NexgenTeamSpeakConnector(xControl).ChannelName(currChannel));
  SyncVariables();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside call when the channel switch of the player was not Successful.
 *
 **************************************************************************************************/
function SwitchFailed() {
  client.showMsg("<C00>Channel switch failed.");
  bChangingChannel = False;
}
 
/***************************************************************************************************
 *
 *  REPLICATED SERVER -> CLIENT FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Clientside replicated Console Command call to connect to the TS server.
 *
 **************************************************************************************************/
simulated function Connect(string url) {
  client.player.ConsoleCommand("start"@url);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Clientside function to save the current TSNick for further use (allows name
 *                changes during map-changes for example).
 *  $PARAM        Nick  The current Nickname used on the TS server.
 *
 **************************************************************************************************/
simulated function saveTSNick(string Nick) {
  client.gc.set(SSTR_TSNick, Nick);
  client.gc.saveConfig();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Clientside replicated Console Command call to toggle between windowed and
 *                fullscreen mode.
 *
 **************************************************************************************************/
simulated function ToggleFullScreen(bool goFullScreen) {
  if(client.gc.get(SSTR_autoToggleScreen, "false") ~= "true") {
    if(goFullScreen) client.player.ConsoleCommand("ToggleFullScreen");
    else             client.player.ConsoleCommand("EndFullScreen");
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Clientside replicated Console Command call to open the Nexgen TS panel
 *
 **************************************************************************************************/
simulated function openTSPanel() {
  if(TSPanel != none) client.showPanel(class'NexgenTeamSpeakConnectorPanel'.default.panelIdentifier);
}

/***************************************************************************************************
 *
 *  REPLICATED CLIENT -> SERVER FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Replicated client -> server functions called by the GUI.
 *
 **************************************************************************************************/
function wantsConnect() {    ConnectToTS();       }
function wantsDisconnect() { Disconnect();        }
function wantsSwitch() {     ChangeChannel(true); }

/***************************************************************************************************
 *
 *  MISC FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Function to determine the channel for this client.
 *
 **************************************************************************************************/
function int findTeamChannel() {
  if(client.team == 0 || !Level.Game.GameReplicationInfo.bTeamGame) return NexgenTeamSpeakConnector(xControl).RedTeamChannelid;
  else if(client.team == 1) return NexgenTeamSpeakConnector(xControl).BlueTeamChannelid;
  else return NexgenTeamSpeakConnector(xControl).SpecTeamChannelid;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Removes special chars from the TS name to ensure compatibility.
 *
 **************************************************************************************************/
function string getSaveTSName(string Name) {
  local string newName;
  
  newName = Name;

  newName = class'NexgenUtil'.static.replace(newName, "|", "");
  newName = class'NexgenUtil'.static.replace(newName, "\\", "");
  newName = class'NexgenUtil'.static.replace(newName, "&", "");
  
  return newName;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the HUD's enabled flag.
 *
 **************************************************************************************************/
simulated function updateHUDStatus() {
  if(xHUD == None) return;
  
  if(int(client.gc.get(SSTR_TSHUDType, "1")) == 2 ||
    (int(client.gc.get(SSTR_TSHUDType, "1")) == 1 && bConnected)) xHUD.bEnabled = true;
  else xHUD.bEnabled = false;   
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the tab caption.
 *
 **************************************************************************************************/
simulated function updateTSPanelCaption() {
  if(TSPanel != none) {
    if(clientAmount == 0)  TSPanel.OwnerTab.SetCaption("Teamspeak");
    else                   TSPanel.OwnerTab.SetCaption("Teamspeak ("$clientAmount$")");
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Wrapper function for NexgenController.logAdminAction() when called clientside.
 *  $PARAM        msg                Message that describes the action performed by the administrator.
 *  $PARAM        str1               Message specific content.
 *  $PARAM        str2               Message specific content.
 *  $PARAM        str3               Message specific content.
 *  $PARAM        bNoBroadcast       Whether not to broadcast this administrator action.
 *  $PARAM        bServerAdminsOnly  Broadcast message only to administrators with the server admin
 *                                   privilege.
 *
 **************************************************************************************************/
function SlogAdminAction(string msg, optional coerce string str1, optional coerce string str2,
                        optional coerce string str3, optional bool bNoBroadcast,
                        optional bool bServerAdminsOnly) {
	control.logAdminAction(client, msg, client.playerName, str1, str2, str3,
	                       client.player.playerReplicationInfo, bNoBroadcast, bServerAdminsOnly);
}

/***************************************************************************************************
 *
 *  QUERY FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Clientside function for starting the channel query.
 *
 **************************************************************************************************/
simulated function queryChannels() {
  local int i;
  
  // Check if we are querying the gameserver to fast
  if(lastQueryTime > 0) {
    if(Level.TimeSeconds - lastQueryTime > queryTimeout) lastQueryTime = 0.0;
    else return;
  }
  
  // Clear buffer
  for(i=0;i<bufferIndex;i++) {
     bufferChannel[i] = 255;
     bufferNames[i]   = "";
     bufferTeam[i]    = 128;
     bufferFlags[i]   = 255;
     bufferCountry[i] = "";
  }
  bufferIndex = 0;

  // Start query
  lastQueryTime = Level.TimeSeconds;
  getTSclients();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside call to collect all users in the channels and send the results over
 *                to the client.
 *
 **************************************************************************************************/
function getTSclients() {
  local int i;
  local NexgenTeamSpeakConnector xxControl;
  
  xxControl = NexgenTeamSpeakConnector(xControl);
  
  for(i=0; i<xxControl.tsQueryDataIndex; i++) {
    if(xxControl.tsChanID[i] > 0 && xxControl.tsChanID[i] < 5) sendStr(CMD_TS_PREFIX @ CMD_TS_CHANNELCLIENTS @ xxControl.tsChanID[i] @ 
                                                                       class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(xxControl.tsName[i]) @ 
                                                                       xxControl.tsTeam[i] @ xxControl.tsFlags[i] @ xxControl.tsCountry[i]); 
  }
  
  sendStr(CMD_TS_PREFIX @ CMD_TS_CHANNELCLIENTS_DONE);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside function to send amount of connected players
 *
 **************************************************************************************************/
function sendClientAmount(byte amount) {
  clientAmount = amount;
  sendStr(CMD_TS_PREFIX @ CMD_TS_CLIENT_AMOUNT @ amount);
}

/***************************************************************************************************
 *
 *  TCP REPLICATION FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a string was received from the other machine.
 *  $PARAM        str  The string that was send by the other machine.
 *
 **************************************************************************************************/
simulated function recvStr(string str) {
	local string cmd;
	local string args[10];
	local int argCount;

	super.recvStr(str);

	// Check controller role.
	if (role != ROLE_Authority) {
		// Commands accepted by client.
		if(class'NexgenUtil'.static.parseCmd(str, cmd, args, argCount, CMD_TS_PREFIX)) {
		  switch (cmd) {
			case CMD_TS_BENABLED:            exec_TS_BENABLED(args, argCount); break;
			case CMD_TS_CHANNELNAMES:        exec_TS_CHANNELNAMES(args, argCount); break;
			case CMD_TS_CHANNELCLIENTS:      exec_TS_CHANNELCLIENTS(args, argCount); break;
			case CMD_TS_CHANNELCLIENTS_DONE: exec_TS_CHANNELCLIENTS_DONE(args, argCount); break;
			case CMD_TS_SERVERVARS:          exec_TS_SERVERVARS(args, argCount); break;
			case CMD_TS_SERVERVARS_SYNCED:   exec_TS_SERVERVARS_SYNCED(args, argCount); break;
      case CMD_TS_CLIENT_AMOUNT:       exec_TS_CLIENT_AMOUNT(args, argCount); break;
		  }
		}
	} else {
    // Commands accepted by server.
    if(class'NexgenUtil'.static.parseCmd(str, cmd, args, argCount, CMD_TS_PREFIX)) {
      switch (cmd) {
        case CMD_TS_CLIENTSETTINGS: exec_TS_CLIENTSETTINGS(args, argCount); break;
      }
    }
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a TS_CLIENTSETTINGS command (client-side).
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_TS_BENABLED(string args[10], int argCount) {
  bEnabled     = bool(args[0]);
  fTimerPeriod = float(args[1]);
  iMode        = byte(args[2]);
  if(bEnabled) {
    xHUD = spawn(class'NexgenTeamSpeakConnectorHUD', self);
    updateHUDStatus();
    TSPanel = NexgenTeamSpeakConnectorPanel(client.mainWindow.mainPanel.addPanel("Teamspeak", class'NexgenTeamSpeakConnectorPanel'));
    updateTSPanelCaption();
    SetTimer(fTimerPeriod/2.0, true);
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a TS_CLIENTSETTINGS command (client-side).
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_TS_CHANNELNAMES(string args[10], int argCount) {

  TSadress                = args[0];
  TSport                  = int(args[1]);
  DefaultChannelname      = args[2];
  MixedChannelname        = args[3];
  RedChannelname          = args[4];
  BlueChannelname         = args[5];
  SpecChannelname         = args[6];
  DisconnectedChannelname = args[7];
  
  if(TSPanel != none) TSPanel.channelNamesReceived();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a TS_CLIENTSETTINGS command (server-side).
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
function exec_TS_CLIENTSETTINGS(string args[10], int argCount) {

  autoTSConnect         = bool(args[0]);
  favTSChannel          = int(args[1]);
  savedTSNick           = args[2];
  bNotifyChannelChanges = bool(args[3]);

  // Initial Replication?
  if(bool(args[argCount-1])) {
    bClientSettingsAvailable = True;
    if(savedTSNick != "") TSNick = savedTSNick;
    else TSNick = getSaveTSName(client.playerName);
    bCheckingInitialTSStatus = True;
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a CMD_TS_CHANNELCLIENTS command (client-side).
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_TS_CHANNELCLIENTS(string args[10], int argCount) {

  if(bufferIndex < ArrayCount(bufferChannel)) {
    bufferChannel[bufferIndex] = byte(args[0]);
    bufferNames  [bufferIndex] = args[1];
    bufferTeam   [bufferIndex] = byte(args[2]);
    bufferFlags  [bufferIndex] = byte(args[3]);
    bufferCountry[bufferIndex] = args[4];
    bufferIndex++;
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a exec_TS_SERVERVARS command (client-side).
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_TS_SERVERVARS(string args[10], int argCount) {

  switch(args[0]) {
    case "bConnecting":      bConnecting       = bool(args[1]); break;
    case "bConnected":       bConnected        = bool(args[1]); break;
    case "currChannel":      currChannelString = args[1];       break;
    case "TSNick":           TSNick            = args[1]; break;
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a exec_TS_SERVERVARS_SYNCED command (client-side).
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_TS_SERVERVARS_SYNCED(string args[10], int argCount) {
  if(TSPanel != none) TSPanel.update();
  updateHUDStatus();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a CMD_TS_CHANNELCLIENTS command (client-side).
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_TS_CHANNELCLIENTS_DONE(string args[10], int argCount) {
  local byte i;
  
  if(TSPanel != none) {
    // Clear old array entries
    for(i=0;i<ArrayCount(mixedChannelNames);i++) {
      mixedChannelNames[i]    = "";
      mixedChannelTeam[i]     = 128;
      mixedChannelFlags[i]    = 255;
      mixedChannelCountry[i]  = "";
      if(i < ArrayCount(redChannelNames)) {
        redChannelNames[i]    = "";
        redChannelTeam[i]     = 128;
        redChannelFlags[i]    = 255;
        redChannelCountry[i]  = "";
        blueChannelNames[i]   = "";
        blueChannelTeam[i]    = 128;
        blueChannelFlags[i]   = 255;
        blueChannelCountry[i] = "";
        specChannelNames[i]   = "";
        specChannelTeam[i]    = 128;
        specChannelFlags[i]   = 255;
        specChannelCountry[i] = "";
      }
    }
    mixedChannelIndex = 0;
    redChannelIndex = 0;
    blueChannelIndex = 0;
    specChannelIndex = 0;

    // Move from buffer to arrays
    for(i=0; i<bufferIndex; i++) {
      switch(bufferChannel[i]) {
        case 1:
          mixedChannelNames  [mixedChannelIndex] = bufferNames[i];
          mixedChannelTeam   [mixedChannelIndex] = bufferTeam[i];
          mixedChannelFlags  [mixedChannelIndex] = bufferFlags[i];
          mixedChannelCountry[mixedChannelIndex] = bufferCountry[i];
          mixedChannelIndex++;
        break;
        case 2:
          redChannelNames  [redChannelIndex] = bufferNames[i];
          redChannelTeam   [redChannelIndex] = bufferTeam[i];
          redChannelFlags  [redChannelIndex] = bufferFlags[i];
          redChannelCountry[redChannelIndex] = bufferCountry[i];
          redChannelIndex++;
        break;
        case 3:
          blueChannelNames  [blueChannelIndex] = bufferNames[i];
          blueChannelTeam   [blueChannelIndex] = bufferTeam[i];
          blueChannelFlags  [blueChannelIndex] = bufferFlags[i];
          blueChannelCountry[blueChannelIndex] = bufferCountry[i];
          blueChannelIndex++;
        break;
        case 4:
          specChannelNames  [specChannelIndex] = bufferNames[i];
          specChannelTeam   [specChannelIndex] = bufferTeam[i];
          specChannelFlags  [specChannelIndex] = bufferFlags[i];
          specChannelCountry[specChannelIndex] = bufferCountry[i];
          specChannelIndex++;
        break;
        default:
        break;
      }
    }
  }
    
  TSPanel.queryDone();
  
  lastQueryTime = 0.0;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Executes a exec_TS_CLIENT_AMOUNT command (client-side).
 *  $PARAM        args      The arguments given for the command.
 *  $PARAM        argCount  Number of arguments available for the command.
 *
 **************************************************************************************************/
simulated function exec_TS_CLIENT_AMOUNT(string args[10], int argCount) {
  clientAmount = byte(args[0]);
  updateTSPanelCaption();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Serverside function called when vars have been changed and need syncing.
 *
 **************************************************************************************************/
function SyncVariables() {

  sendStr(CMD_TS_PREFIX @ CMD_TS_SERVERVARS @ "bConnecting" @ bConnecting);
  sendStr(CMD_TS_PREFIX @ CMD_TS_SERVERVARS @ "bConnected"  @ bConnected);
  sendStr(CMD_TS_PREFIX @ CMD_TS_SERVERVARS @ "currChannel" @ class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(NexgenTeamSpeakConnector(xControl).ChannelName(currChannel)));
  sendStr(CMD_TS_PREFIX @ CMD_TS_SERVERVARS @ "TSNick"      @ TSNick);

  sendStr(CMD_TS_PREFIX @ CMD_TS_SERVERVARS_SYNCED);
}

/***************************************************************************************************
 *
 *  Below are fixed functions for the Empty String TCP bug. Check out this article to read more
 *  about it: http://www.unrealadmin.org/forums/showthread.php?t=31280
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Fixed version of the setVar function in NexgenExtendedClientController.
 *                Empty strings are now formated correctly before beeing sent to the server.
 *
 **************************************************************************************************/
simulated function setVar(string dataContainerID, string varName, coerce string value, optional int index) {
	local NexgenSharedDataContainer dataContainer;
	local string oldValue;
	local string newValue;

	// Get data container.
	dataContainer = dataSyncMgr.getDataContainer(dataContainerID);

	// Check if variable can be updated.
	if (dataContainer == none || !dataContainer.mayWrite(self, varName)) return;

	// Update variable value.
	oldValue = dataContainer.getString(varName, index);
	dataContainer.set(varName, value, index);
	newValue = dataContainer.getString(varName, index);

	// Send new value to server.
	if (newValue != oldValue) {
		if (dataContainer.isArray(varName)) {
			sendStr(CMD_SYNC_PREFIX @ CMD_UPDATE_VAR
			        @ class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(dataContainerID)
			        @ class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(varName)
			        @ index
			        @ class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(newValue));
		} else {
			sendStr(CMD_SYNC_PREFIX @ CMD_UPDATE_VAR
			        @ class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(dataContainerID)
			        @ class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(varName)
			        @ class'NexgenTeamSpeakConnector'.static.formatCmdArgFixed(newValue));
		}
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Corrected version of the exec_UPDATE_VAR function in NexgenExtendedClientController.
 *                Due to the invalid format function, empty strings weren't sent correctly and were
 *                therefore not identifiable for the other machine (server). This caused the var index
 *                being erroneously recognized as the new var value on the server.
 *                Since the serverside set() function in NexgenSharedDataSyncManager also uses the
 *                invalid format functions, I implemented a fixed function in NexgenTeamSpeakConnector. The
 *                client side set() function can still be called safely without problems.
 *
 **************************************************************************************************/
simulated function exec_UPDATE_VAR(string args[10], int argCount) {
	local int varIndex;
	local string varName;
	local string varValue;
	local NexgenSharedDataContainer container;
	local int index;

	// Get arguments.
	if (argCount == 3) {
		varName = args[1];
		varValue = args[2];
	} else if (argCount == 4) {
		varName = args[1];
		varIndex = int(args[2]);
		varValue = args[3];
	} else {
		return;
	}

	if (role == ROLE_Authority) {
  	// Server side, call fixed set() function
  	NexgenTeamSpeakConnector(xControl).setFixed(args[0], varName, varValue, varIndex, self);
  } else {

    // Client Side
    dataSyncMgr.set(args[0], varName, varValue, varIndex, self);

    container = dataSyncMgr.getDataContainer(args[0]);

		// Signal event to client controllers.
		for (index = 0; index < client.clientCtrlCount; index++) {
			if (NexgenExtendedClientController(client.clientCtrl[index]) != none) {
				NexgenExtendedClientController(client.clientCtrl[index]).varChanged(container, varName, varIndex);
			}
		}

		// Signal event to GUI.
		client.mainWindow.mainPanel.varChanged(container, varName, varIndex);
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     ctrlID="NexgenTeamSpeakConnectorClient"
     currChannel=-1
     newChannel=-1
}