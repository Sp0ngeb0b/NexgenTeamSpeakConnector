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
class NexgenTeamSpeakConnectorPanelMulti extends NexgenPanel;

// Links
var NexgenTeamSpeakConnectorPanel xPanel;
var NexgenTeamSpeakConnectorClient xClient;           // Client belonging to this GUI

// Lists
var NexgenTeamSpeakConnectorListBox mixedChannelList;
var NexgenTeamSpeakConnectorListBox redChannelList;
var NexgenTeamSpeakConnectorListBox specChannelList;
var NexgenTeamSpeakConnectorListBox blueChannelList;

// Labels
var UMenuLabelControl mixedChannelLabel;
var UMenuLabelControl redChannelLabel;
var UMenuLabelControl specChannelLabel;
var UMenuLabelControl blueChannelLabel;

var int blueListRegion;

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
	divideRegionV(2, defaultComponentDist);
	divideRegionH(2, defaultComponentDist);
	divideRegionH(2, defaultComponentDist);
	splitRegionH(16, defaultComponentDist);
	splitRegionH(16, defaultComponentDist);
	splitRegionH(16, defaultComponentDist);
	splitRegionH(16, defaultComponentDist);
	mixedChannelLabel = addLabel("", true, TA_Center);
	mixedChannelList = NexgenTeamSpeakConnectorListBox(addListBox(class'NexgenTeamSpeakConnectorListBox'));
	redChannelLabel = addLabel("", true, TA_Center);
	redChannelList = NexgenTeamSpeakConnectorListBox(addListBox(class'NexgenTeamSpeakConnectorListBox'));
	specChannelLabel = addLabel("", true, TA_Center);
	specChannelList = NexgenTeamSpeakConnectorListBox(addListBox(class'NexgenTeamSpeakConnectorListBox'));
	blueChannelLabel = addLabel("", true, TA_Center);
	blueListRegion = currRegion;
	skipRegion();
  
  // Configure Components
  mixedChannelList.bShowCountryFlag=false;
  redChannelList.bShowCountryFlag=false; 
  specChannelList.bShowCountryFlag=false;
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
  redChannelList.items.clear();
  specChannelList.items.clear();
  if(blueChannelList != none) blueChannelList.items.clear();
  
  // Update with new entries
  xPanel.updateListBox_64(mixedChannelList,  xClient.mixedChannelNames, xClient.mixedChannelTeam, xClient.mixedChannelCountry, xClient.mixedChannelFlags); 
  xPanel.updateListBox_16(redChannelList,    xClient.redChannelNames,   xClient.redChannelTeam,   xClient.redChannelCountry,   xClient.redChannelFlags);    
  if(blueChannelList != none) {
    xPanel.updateListBox_16(blueChannelList, xClient.blueChannelNames,  xClient.blueChannelTeam,  xClient.blueChannelCountry,  xClient.blueChannelFlags);    
  }
  xPanel.updateListBox_16(specChannelList,   xClient.specChannelNames,  xClient.specChannelTeam,  xClient.specChannelCountry,  xClient.specChannelFlags);    
  
  // Update xClient lists sorted by name
  xPanel.getSortedList_64(mixedChannelList,  xClient.mixedChannelNames, xClient.mixedChannelFlags, xClient.mixedChannelTeam, xClient.mixedChannelCountry);
  xPanel.getSortedList_16(redChannelList,    xClient.redChannelNames,   xClient.redChannelFlags,   xClient.redChannelTeam,   xClient.redChannelCountry);
  if(blueChannelList != none) {
    xPanel.getSortedList_16(blueChannelList, xClient.blueChannelNames,  xClient.blueChannelFlags,  xClient.blueChannelTeam,  xClient.blueChannelCountry);
  }
  xPanel.getSortedList_16(specChannelList,   xClient.specChannelNames,  xClient.specChannelFlags,  xClient.specChannelTeam,  xClient.specChannelCountry);

} 

/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the Channel name labels.
 *
 **************************************************************************************************/
function channelNamesReceived() {

  mixedChannelLabel.setText(xClient.mixedChannelname);
  redChannelLabel.setText(xClient.redChannelname);
  blueChannelLabel.setText(xClient.blueChannelname);
  if(xClient.blueChannelname != "") {
    selectRegion(blueListRegion);
    blueChannelList = NexgenTeamSpeakConnectorListBox(addListBox(class'NexgenTeamSpeakConnectorListBox'));
    blueChannelList.bShowCountryFlag=false;
  }
  specChannelLabel.setText(xClient.specChannelname);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the sorted lists for the HUD overlay.
 *
 **************************************************************************************************/
function getSortedLists(out string names[68], out byte team[68], out byte flags[68]) {
  local NexgenTeamSpeakConnectorItem item;
  local byte i;
  
  for(item = NexgenTeamSpeakConnectorItem(mixedChannelList.items); item != none && i < ArrayCount(names); item = NexgenTeamSpeakConnectorItem(item.next)) {
    names[i]   = item.pName;
    team[i]    = item.pTeam;
    flags[i]   = item.tsFlags;
    i++;
  }
  i++;
  for(item = NexgenTeamSpeakConnectorItem(redChannelList.items); item != none && i < ArrayCount(names); item = NexgenTeamSpeakConnectorItem(item.next)) {
    names[i]   = item.pName;
    team[i]    = item.pTeam;
    flags[i]   = item.tsFlags;
    i++;
  }
  i++;
  for(item = NexgenTeamSpeakConnectorItem(blueChannelList.items); item != none && i < ArrayCount(names); item = NexgenTeamSpeakConnectorItem(item.next)) {
    names[i]   = item.pName;
    team[i]    = item.pTeam;
    flags[i]   = item.tsFlags;
    i++;
  }
  i++;
  for(item = NexgenTeamSpeakConnectorItem(specChannelList.items); item != none && i < ArrayCount(names); item = NexgenTeamSpeakConnectorItem(item.next)) {
    names[i]   = item.pName;
    team[i]    = item.pTeam;
    flags[i]   = item.tsFlags;
    i++;
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
}
