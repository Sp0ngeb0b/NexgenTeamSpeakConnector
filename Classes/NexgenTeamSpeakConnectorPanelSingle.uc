/*##################################################################################################
##
##  Nexgen Teamspeak 3 Connector version 2.00
##  Copyright (C) 2019 Patrick "Sp0ngeb0b" Peltzer
##
##  This program is free software; you can redistribute and/or modify
##  it under the terms of the Open Unreal Mod License version 1.1.
##
##  Contact: spongebobut@yahoo.com | www.unrealriders.eu
##
##################################################################################################*/
class NexgenTeamSpeakConnectorPanelSingle extends NexgenPanel;

// Links
var NexgenTeamSpeakConnectorPanel xPanel;
var NexgenTeamSpeakConnectorClient xClient;           // Client belonging to this GUI

// Lists
var NexgenTeamSpeakConnectorListBox mixedChannelList;

// Labels
var UMenuLabelControl serverAdressLabel, mixedChannelLabel;

/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
  local int region;

	// Get client controller.
  xPanel  = NexgenTeamSpeakConnectorPanel(parentCP); 
	xClient = xPanel.xClient;

	// Create layout & add components.
	createPanelRootRegion();
	
	// Left Panel
	splitRegionH(16, defaultComponentDist);
	serverAdressLabel = addLabel("", true, TA_Center);
  splitRegionH(16, defaultComponentDist);
  mixedChannelLabel = addLabel("", true, TA_Center);
	mixedChannelList = NexgenTeamSpeakConnectorListBox(addListBox(class'NexgenTeamSpeakConnectorListBox'));
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when a general event has occurred in the system.
 *  $PARAM        type      The type of event that has occurred.
 *  $PARAM        argument  Optional arguments providing details about the event.
 *
 **************************************************************************************************/
function notifyEvent(string type, optional string arguments) {
	switch(type) {
    case "queryDone":            queryDone();            break;
    case "channelNamesReceived": channelNamesReceived(); break;
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the Channel lists.
 *
 **************************************************************************************************/
function queryDone() {
  local int i;
  
  // Clear lists
  mixedChannelList.items.clear();
  
  // Update with new entries
  xPanel.updateListBox_64(mixedChannelList, xClient.mixedChannelNames, xClient.mixedChannelTeam, xClient.mixedChannelCountry, xClient.mixedChannelFlags); 
  
  // Update xClient list sorted by name
  xPanel.getSortedList_64(mixedChannelList, xClient.mixedChannelNames, xClient.mixedChannelFlags, xClient.mixedChannelTeam, xClient.mixedChannelCountry);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the Channel name labels.
 *
 **************************************************************************************************/
function channelNamesReceived() {
  serverAdressLabel.setText(xClient.TSadress$":"$xClient.TSport);
  mixedChannelLabel.setText(xClient.defaultChannelname);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
}
