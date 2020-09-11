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
class NexgenTeamSpeakConnectorPanel extends NexgenPanel;

#exec TEXTURE IMPORT NAME=tslogo     FILE=Resources\tslogo.pcx GROUP="GFX" 	   FLAGS=1 MIPS=On

// Links
var NexgenTeamSpeakConnectorClient xClient;           // Client belonging to this GUI

// Elements
var UWindowSmallButton connectionButton;
var UWindowSmallButton switchChannelButton;
var UWindowSmallButton downloadTSButton;
var UWindowSmallButton userGuideButton;
var UWindowCheckbox bAutoTSConnectInp;
var UWindowCheckbox bAutoToggleScreenInp;
var UWindowCheckbox bNotifyChannelChangesInp;
var UWindowComboControl favChannelInp;
var UWindowComboControl hudStatusInp;

var UMenuLabelControl statusLabel;
var UMenuLabelControl channelLabel;
var UMenuLabelControl flagsLabel;

var NexgenContentPanel p2, p3, p4;
var NexgenPanel listPanel;

// Colors
var Color greenColor, yellowColor, redColor;

// Possible sub panels
var class<NexgenPanel> listPanels[2];

/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
  local int region;

	// Get client controller.
	xClient = NexgenTeamSpeakConnectorClient(client.getController(class'NexgenTeamSpeakConnectorClient'.default.ctrlID));

	// Create layout & add components.
	createWindowRootRegion();
	splitRegionV(40, defaultComponentDist, true, true);
	listPanel = addSubPanel(listPanels[xClient.iMode]);
	
  // Right Panels
  selectRegion(splitRegionH(30, defaultComponentDist, true));
  p2 = addContentPanel();
  splitRegionH(56, defaultComponentDist, true);
  p3 = addContentPanel();
  splitRegionH(96, defaultComponentDist, true);
  p4 = addContentPanel();
  
  // Control Panel
  p2.splitRegionH(16, defaultComponentDist);
  p2.addLabel("Control Panel", true, TA_Center);
  p2.divideRegionH(4, defaultComponentDist);
  p2.SplitRegionV(48, defaultComponentDist);
  p2.SplitRegionV(48, defaultComponentDist);
  p2.SplitRegionV(96, defaultComponentDist);
  p2.divideRegionV(2, defaultComponentDist);
  p2.addLabel("Status", true, TA_Left);
  statusLabel = p2.addLabel("", true, TA_Left);
  p2.addLabel("Flags", true, TA_Left);
  flagsLabel = p2.addLabel("", true, TA_Left);
  if(xClient.iMode == 1) p2.addLabel("Current Channel", true, TA_Left);
  else p2.skipRegion();
  channelLabel = p2.addLabel("", true, TA_Left);
  connectionButton      = p2.addButton("Connect", , AL_Center);
  switchChannelButton   = p2.addButton("Switch Channel", , AL_Center);
  
  // Client Settings
  p3.splitRegionH(16, defaultComponentDist);
  p3.addLabel("Client Settings", true, TA_Center);
  p3.divideRegionH(5, defaultComponentDist);
  bAutoTSConnectInp = p3.addCheckBox(TA_Left, "Auto connect to TS on join", true);
  bAutoToggleScreenInp = p3.addCheckBox(TA_Left, "Connect in windowed mode", true);
  bNotifyChannelChangesInp = p3.addCheckBox(TA_Left, "Message on channel joins/leaves", true);
  p3.splitRegionV(112, defaultComponentDist);
  p3.splitRegionV(112, defaultComponentDist);
  p3.addLabel("Default TS channel:", true, TA_Left);
  if(xClient.iMode != 0) favChannelInp = p3.addListCombo();
  else                   p3.addLabel("N/A", false, TA_Center);    
  p3.addLabel("HUD Overlay enabled:", true, TA_Left);
  hudStatusInp = p3.addListCombo();
  
  // TS/plugin Info
  p4.splitRegionH(64, defaultComponentDist, , true);
  p4.addLabel(Class'NexgenTeamSpeakConnector'.default.pluginName, true, TA_Center);
  p4.splitRegionV(64, defaultComponentDist, , true);
  p4.splitRegionH(14, defaultComponentDist, , true);
  p4.addImageBox(Texture'tslogo');
  p4.splitRegionH(8, defaultComponentDist);
  p4.addLabel("By"@Class'NexgenTeamSpeakConnector'.default.pluginAuthor, true, TA_Center);
  p4.skipRegion();
  p4.divideRegionH(2, defaultComponentDist);
  userGuideButton = p4.addButton("User Manual", 100, AL_Center);
  downloadTSButton = p4.addButton("Download Teamspeak 3", 126, AL_Center);
	
  // Configure Components
	statusLabel.setText("*Disconnected*");
  statusLabel.SetTextColor(redColor);
  switchChannelButton.bDisabled = true;
  bAutoTSConnectInp.register(self);
	bAutoTSConnectInp.bChecked = xClient.client.gc.get(xClient.SSTR_AutoTSConnect, "false") ~= "true";
	bAutoToggleScreenInp.register(self);
	bAutoToggleScreenInp.bChecked = xClient.client.gc.get(xClient.SSTR_autoToggleScreen, "false") ~= "true";
	bNotifyChannelChangesInp.register(self);
	bNotifyChannelChangesInp.bChecked = xClient.client.gc.get(xClient.SSTR_bNotifyChannelChanges, "true") ~= "true";
	if(xClient.iMode != 0) {
    favChannelInp.register(self);
    favChannelInp.addItem("Mixed Channel", "0");
    favChannelInp.addItem("Team Channel", "1");
    favChannelInp.setSelectedIndex(int(xClient.client.gc.get(xClient.SSTR_FavTSChannel, "0")));
  }
  hudStatusInp.register(self);
	hudStatusInp.addItem("Never", "0");
	hudStatusInp.addItem("When connected", "1");
	hudStatusInp.addItem("Always", "1");
	hudStatusInp.setSelectedIndex(int(xClient.client.gc.get(xClient.SSTR_TSHUDType, "1")));
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Notifies the dialog of an event (caused by user interaction with the interface).
 *  $PARAM        control    The control object where the event was triggered.
 *  $PARAM        eventType  Identifier for the type of event that has occurred.
 *  $REQUIRE      control != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function notify(UWindowDialogControl control, byte eventType) {
	super.notify(control, eventType);

  if(control == connectionButton && !connectionButton.bDisabled && eventType == DE_Click) {
    if(xClient.bConnected) xClient.wantsDisconnect();
    else xClient.wantsConnect();
  } else if(control == switchChannelButton && !switchChannelButton.bDisabled && eventType == DE_Click) {
    xClient.wantsSwitch();
  } else if(control == bAutoTSConnectInp && eventType == DE_Click) {
    // Save setting.
		xClient.client.gc.set(xClient.SSTR_AutoTSConnect, string(bAutoTSConnectInp.bChecked));
		xClient.client.gc.saveConfig();
		xClient.sendStr(xClient.CMD_TS_PREFIX @ xClient.CMD_TS_CLIENTSETTINGS @ xClient.client.gc.get(xClient.SSTR_AutoTSConnect, "false") @
    xClient.client.gc.get(xClient.SSTR_FavTSChannel, "0") @ xClient.client.gc.get(xClient.SSTR_TSNick, "") @ xClient.client.gc.get(xClient.SSTR_bNotifyChannelChanges, "true") @ false);
  } else if(control == bNotifyChannelChangesInp && eventType == DE_Click) {
    // Save setting.
		xClient.client.gc.set(xClient.SSTR_bNotifyChannelChanges, string(bNotifyChannelChangesInp.bChecked));
		xClient.client.gc.saveConfig();
		xClient.sendStr(xClient.CMD_TS_PREFIX @ xClient.CMD_TS_CLIENTSETTINGS @ xClient.client.gc.get(xClient.SSTR_AutoTSConnect, "false") @
    xClient.client.gc.get(xClient.SSTR_FavTSChannel, "0") @ xClient.client.gc.get(xClient.SSTR_TSNick, "") @ xClient.client.gc.get(xClient.SSTR_bNotifyChannelChanges, "true") @ false);
  } else if(xClient.iMode != 0 && control == favChannelInp && eventType == DE_Change) {
    // Save setting.
		xClient.client.gc.set(xClient.SSTR_FavTSChannel, string(favChannelInp.getSelectedIndex()));
		xClient.client.gc.saveConfig();
		xClient.sendStr(xClient.CMD_TS_PREFIX @ xClient.CMD_TS_CLIENTSETTINGS @ xClient.client.gc.get(xClient.SSTR_AutoTSConnect, "false") @
    xClient.client.gc.get(xClient.SSTR_FavTSChannel, "0") @ xClient.client.gc.get(xClient.SSTR_TSNick, "") @ xClient.client.gc.get(xClient.SSTR_bNotifyChannelChanges, "true") @ false);
  } else if(control == hudStatusInp && eventType == DE_Change) {
    // Save setting.
		xClient.client.gc.set(xClient.SSTR_TSHUDType, string(hudStatusInp.getSelectedIndex()));
		xClient.client.gc.saveConfig();
    xClient.updateHUDStatus();
  } else if(control == bAutoToggleScreenInp && eventType == DE_Click) {
    xClient.client.gc.set(xClient.SSTR_autoToggleScreen, string(bAutoToggleScreenInp.bChecked));
		xClient.client.gc.saveConfig();
  } else if(control == downloadTSButton && eventType == DE_Click) {
    xClient.client.player.ConsoleCommand("start http://www.teamspeak.com/?page=downloads");
  } else if(control == userGuideButton && eventType == DE_Click) {
    xClient.client.showPopup(string(class'NexgenTeamSpeakConnectorGuide'));
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the GUI.
 *
 **************************************************************************************************/
function Update() {
  if(xClient.bConnecting) {
    if(xClient.bConnecting) statusLabel.setText("*Connecting*");
    statusLabel.SetTextColor(yellowColor);
    connectionButton.bDisabled = True;
    switchChannelButton.bDisabled = True;
  } else {
    if(xClient.bConnected) {
      statusLabel.setText("*Connected*");
      statusLabel.SetTextColor(greenColor);
      connectionButton.SetText("Disconnect");
      if(xClient.iMode == 1) switchChannelButton.bDisabled = False;
    } else {
      statusLabel.setText("*Disconnected*");
      statusLabel.SetTextColor(redColor);
      connectionButton.SetText("Connect");
      switchChannelButton.bDisabled = True;
      flagsLabel.setText("");
    }
     connectionButton.bDisabled = False;
  }
  if(xClient.iMode == 1) channelLabel.setText(xClient.currChannelString);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the Channel name labels.
 *
 **************************************************************************************************/
function channelNamesReceived() {
  listPanel.notifyEvent("channelNamesReceived");
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the Channel lists.
 *
 **************************************************************************************************/
function queryDone() {
  listPanel.notifyEvent("queryDone");
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the TS channel lists with 64 possible entries
 *
 **************************************************************************************************/
function updateListBox_64(NexgenTeamSpeakConnectorListBox list, string names[64], byte team[64], string country[64], byte flags[64]) {
  local byte i;
  local NexgenTeamSpeakConnectorItem item;
  
  for(i=0;i<ArrayCount(names);i++) {
    if(xClient.bConnected && names[i] == xClient.TSNick) updateFlagsLabel(flags[i]);
    if(names[i] != "") {
      item          = NexgenTeamSpeakConnectorItem(list.items.append(class'NexgenTeamSpeakConnectorItem'));
  	  item.pName    = names[i];
      item.pTeam    = team[i];
      item.pCountry = country[i];
      item.tsFlags  = flags[i];
    }
  }
  list.items.sort();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the TS channel list with 16 possible entries
 *
 **************************************************************************************************/
function updateListBox_16(NexgenTeamSpeakConnectorListBox list, string names[16], byte team[16], string country[16], byte flags[16]) {
  local byte i;
  local NexgenTeamSpeakConnectorItem item;
  
  for(i=0;i<ArrayCount(names);i++) {
    if(names[i] != "") {
      if(xClient.bConnected && names[i] == xClient.TSNick) updateFlagsLabel(flags[i]);
      item          = NexgenTeamSpeakConnectorItem(list.items.append(class'NexgenTeamSpeakConnectorItem'));
  	  item.pName    = names[i];
      item.pTeam    = team[i];
      item.pCountry = country[i];
      item.tsFlags  = flags[i];
    }
  }
  list.items.sort();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the sorted list.
 *
 **************************************************************************************************/
function getSortedList_64(NexgenTeamSpeakConnectorListBox list, out string names[64], out byte flags[64], out byte team[64], out string country[64]) {
  local NexgenTeamSpeakConnectorItem item;
  local byte i;
  
  for(item = NexgenTeamSpeakConnectorItem(list.items); item != none && i < ArrayCount(names); item = NexgenTeamSpeakConnectorItem(item.next)) {
    if(item.pName != "") {
      names[i]   = item.pName;
      flags[i]   = item.tsFlags;
      team[i]    = item.pTeam;
      country[i] = item.pCountry;
      i++;
    }
  }  
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the sorted list.
 *
 **************************************************************************************************/
function getSortedList_16(NexgenTeamSpeakConnectorListBox list, out string names[16], out byte flags[16], out byte team[16], out string country[16]) {
  local NexgenTeamSpeakConnectorItem item;
  local byte i;
  
  for(item = NexgenTeamSpeakConnectorItem(list.items); item != none && i < ArrayCount(names); item = NexgenTeamSpeakConnectorItem(item.next)) {
    if(item.pName != "") {
      names[i]   = item.pName;
      flags[i]   = item.tsFlags;
      team[i]    = item.pTeam;
      country[i] = item.pCountry;
      i++;
    }
  }  
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the flag label accordingly.
 *
 **************************************************************************************************/
function updateFlagsLabel(byte flags) {
  if(flags < 4)         flagsLabel.setText("No microphone");
  else if(flags-4 > 1)  flagsLabel.setText("Microphone muted");
  else if(flags-4 == 1) flagsLabel.setText("Talking");
  else                  flagsLabel.setText("Standby");
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
 
defaultproperties
{
     panelIdentifier="NexgenTeamSpeakConnectorPanel"
     greenColor=(G=100)
     yellowColor=(R=250,G=250)
     redColor=(R=200)
     listPanels(0)=class'NexgenTeamSpeakConnectorPanelSingle'
     listPanels(1)=class'NexgenTeamSpeakConnectorPanelMulti'
}


