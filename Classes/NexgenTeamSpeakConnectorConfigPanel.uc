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
class NexgenTeamSpeakConnectorConfigPanel extends NexgenPanel;

// Components
var UWindowCheckbox bEnabledInp;
var UWindowCheckbox bInternalDebuggingInp;
var NexgenEditControl fTimerPeriodInp;
var UWindowComboControl iModeInp;
var NexgenEditControl TSadressInp;
var NexgenEditControl TSportInp;
var NexgenEditControl TSqueryportInp;
var NexgenEditControl TSpasswordInp;
var NexgenEditControl TSusernameInp;
var NexgenEditControl TSuserpasswordInp;
var NexgenEditControl DefaultChannelpwInp;
var NexgenEditControl DefaultChannelInp;
var NexgenEditControl MixedChannelInp;
var NexgenEditControl RedChannelInp;
var NexgenEditControl BlueChannelInp;
var NexgenEditControl SpecChannelInp;
var NexgenEditControl DisconnectedChannelInp;

var UWindowSmallButton resetButton;
var UWindowSmallButton saveButton;

// Links
var NexgenTeamSpeakConnectorClient xClient;
var NexgenSharedDataContainer configData;

/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the contents of the panel.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function setContent() {
  local int region;

	// Retrieve client controller interface.
	xClient = NexgenTeamSpeakConnectorClient(client.getController(class'NexgenTeamSpeakConnectorClient'.default.ctrlID));

	// Create layout & add components.
	createPanelRootRegion();
	splitRegionH(16, defaultComponentDist);
	addLabel("NexgenTeamSpeakConnector Connector - Settings", true, TA_Center);
	
	splitRegionH(1, defaultComponentDist);
	addComponent(class'NexgenDummyComponent');
	
	splitRegionH(20, defaultComponentDist, , true);
	region = currRegion;
	skipRegion();
	splitRegionV(196, , , true);
	skipRegion();
	divideRegionV(2, defaultComponentDist);
	saveButton = addButton(client.lng.saveTxt);
	resetButton = addButton(client.lng.resetTxt);

	selectRegion(region);
	selectRegion(splitRegionH(16, defaultComponentDist));
	divideRegionV(2, defaultComponentDist);
	divideRegionV(2, defaultComponentDist);
	bEnabledInp = addCheckBox(TA_Left, "Enable Teamspeak Connector", true);
  bInternalDebuggingInp = addCheckBox(TA_Left, "Write internal debug log", true);
	splitRegionV(136, defaultComponentDist);
	splitRegionV(148, defaultComponentDist);
	
	divideRegionH(8, defaultComponentDist);
	divideRegionH(8, defaultComponentDist);
	divideRegionH(8, defaultComponentDist);
	divideRegionH(8, defaultComponentDist);
	
  addLabel("Query timer period", true, TA_LEFT);
  addLabel("Mode", true, TA_Left);
	addLabel("Teamspeak adress", true, TA_Left);
	addLabel("Teamspeak join Port", true, TA_Left);
	addLabel("Teamspeak query Port", true, TA_Left);
	addLabel("Teamspeak password", true, TA_Left);
	addLabel("Teamspeak username", true, TA_Left);
	addLabel("Teamspeak userpassword", true, TA_Left);

  fTimerPeriodInp   = addEditBox(, 30, AL_RIGHT);  
  iModeInp          = addListCombo();
  TSadressInp       = addEditBox();
  TSportInp         = addEditBox();
  TSqueryportInp    = addEditBox();
  TSpasswordInp     = addEditBox();
  TSusernameInp     = addEditBox();
  TSuserpasswordInp = addEditBox();
	
  skipRegion();
	addLabel("Default Channel password", true, TA_Left);
	addLabel("Default Channel", true, TA_Left);
	addLabel("Mixed Channel", true, TA_Left);
	addLabel("Red Team Channel", true, TA_Left);
	addLabel("Blue Team Channel", true, TA_Left);
	addLabel("Spectator Channel", true, TA_Left);
	addLabel("Disconnected Player Channel", true, TA_Left);
	
  skipRegion();
	DefaultChannelpwInp    = addEditBox();
  DefaultChannelInp      = addEditBox();
  MixedChannelInp        = addEditBox();
  RedChannelInp          = addEditBox();
  BlueChannelInp         = addEditBox();
  SpecChannelInp         = addEditBox();
  DisconnectedChannelInp = addEditBox();
	
	// Configure Components
	resetButton.bDisabled = true;
	saveButton.bDisabled = true;
	
  iModeInp.register(self);
  iModeInp.addItem("Single Channel");
  iModeInp.addItem("Multi Channel");
  
  fTimerPeriodInp.setNumericOnly(true);
  fTimerPeriodInp.SetNumericFloat(true);
  fTimerPeriodInp.setMaxLength(4);
	TSportInp.setNumericOnly(true);
	TSportInp.setMaxLength(5);
  TSqueryportInp.setNumericOnly(true);
	TSqueryportInp.setMaxLength(5);
}

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
function dataContainerAvailable(NexgenSharedDataContainer container) {
  if (container.containerID == class'NexgenTeamSpeakConnectorConfigDC'.default.containerID) {
		configData = container;
		setValues();
		resetButton.bDisabled = false;
		saveButton.bDisabled = false;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets the values of all input components to the current settings.
 *
 **************************************************************************************************/
function setValues() {
	local string fTimerPeriodString;
  
	// Quit if configuration is not available.
	if (configData == none) return;
	
  bEnabledInp.bChecked = configData.getBool("bEnabled");
  bInternalDebuggingInp.bChecked = configData.getBool("bInternalDebugging");
  fTimerPeriodString = configData.getString("fTimerPeriod");
  fTimerPeriodInp.setValue(Left(fTimerPeriodString, InStr(fTimerPeriodString, ".")+3));
  iModeInp.setSelectedIndex(configData.getByte("iMode"));
  TSadressInp.setValue(configData.getString("TSadress"));
  TSportInp.setValue(configData.getString("TSport"));
  TSqueryportInp.setValue(configData.getString("TSqueryport"));
  TSpasswordInp.setValue(configData.getString("TSpassword"));
  TSusernameInp.setValue(configData.getString("TSusername"));
  TSuserpasswordInp.setValue(configData.getString("TSuserpassword"));
  DefaultChannelpwInp.setValue(configData.getString("DefaultChannelpw"));
  DefaultChannelInp.setValue(configData.getString("DefaultChannel"));
  MixedChannelInp.setValue(configData.getString("MixedChannel"));
  RedChannelInp.setValue(configData.getString("RedChannel"));
  BlueChannelInp.setValue(configData.getString("BlueChannel"));
  SpecChannelInp.setValue(configData.getString("SpecChannel"));
  DisconnectedChannelInp.setValue(configData.getString("DisconnectedChannel"));
  
  modeUpdated();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Called when the value of a shared variable has been updated.
 *  $PARAM        container  Shared data container that contains the updated variable.
 *  $PARAM        varName    Name of the variable that was updated.
 *  $PARAM        index      Element index of the array variable that was changed.
 *  $REQUIRE      container != none && varName != "" && index >= 0
 *  $OVERRIDE
 *
 ***************************************************************************************************/
function varChanged(NexgenSharedDataContainer container, string varName, optional int index) {
	local string fTimerPeriodString;

	if (container.containerID ~= class'NexgenTeamSpeakConnectorConfigDC'.default.containerID) {
		switch (varName) {
	 		case "bEnabled":            bEnabledInp.bChecked = container.getBool(varName);             break;
	 		case "bInternalDebugging":  bInternalDebuggingInp.bChecked = container.getBool(varName);   break;
      case "fTimerPeriod":        fTimerPeriodString = configData.getString(varName);
                                  fTimerPeriodInp.setValue(
                                  Left(fTimerPeriodString, InStr(fTimerPeriodString, ".")+3));   break;        
      case "iMode":               iModeInp.setSelectedIndex(configData.getByte(varName));        break;
	 		case "TSadress":            TSadressInp.setValue(container.getString(varName));            break;
	 		case "TSport":              TSportInp.setValue(container.getString(varName));              break;
	 		case "TSqueryport":         TSqueryportInp.setValue(container.getString(varName));         break;
	 		case "TSpassword":          TSpasswordInp.setValue(container.getString(varName));          break;
	 		case "TSusername":          TSusernameInp.setValue(container.getString(varName));          break;
	 		case "TSuserpassword":      TSuserpasswordInp.setValue(container.getString(varName));      break;
	 		case "DefaultChannelpw":    DefaultChannelpwInp.setValue(container.getString(varName));    break;
	 		case "DefaultChannel":      DefaultChannelInp.setValue(container.getString(varName));      break;
	 		case "MixedChannel":        MixedChannelInp.setValue(container.getString(varName));        break;
	 		case "RedChannel":          RedChannelInp.setValue(container.getString(varName));          break;
	 		case "BlueChannel":         BlueChannelInp.setValue(container.getString(varName));         break;
	 		case "SpecChannel":         SpecChannelInp.setValue(container.getString(varName));         break;
	 		case "DisconnectedChannel": DisconnectedChannelInp.setValue(container.getString(varName)); break;
		}
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the current settings.
 *
 **************************************************************************************************/
function saveSettings() {

	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "bEnabled", bEnabledInp.bChecked);
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "bInternalDebugging", bInternalDebuggingInp.bChecked);
  xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "fTimerPeriod", fTimerPeriodInp.getValue());
  xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "iMode", iModeInp.getSelectedIndex());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "TSadress", TSadressInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "TSport", TSportInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "TSqueryport", TSqueryportInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "TSpassword", TSpasswordInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "TSusername", TSusernameInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "TSuserpassword", TSuserpasswordInp.getValue());
  xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "DefaultChannelpw", DefaultChannelpwInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "DefaultChannel", DefaultChannelInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "MixedChannel", MixedChannelInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "RedChannel", RedChannelInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "BlueChannel", BlueChannelInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "SpecChannel", SpecChannelInp.getValue());
	xClient.setVar(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID, "DisconnectedChannel", DisconnectedChannelInp.getValue());
	xClient.saveSharedData(class'NexgenTeamSpeakConnectorConfigDC'.default.containerID);
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

	// Button pressed?
	if (control != none && eventType == DE_Click && control.isA('UWindowSmallButton') &&
	    !UWindowSmallButton(control).bDisabled) {

		switch (control) {
			case resetButton: setValues(); break;
			case saveButton: saveSettings(); break;
		}
	}
  
  // Mode changed.
	if (control == iModeInp && eventType == DE_Change) {
		modeUpdated();
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Enables/disabled inputs depending on iMode
 *
 **************************************************************************************************/
function modeUpdated() {
  local bool disable;
  
  disable = !bool(iModeInp.getSelectedIndex());

  MixedChannelInp.setDisabled(disable);
  RedChannelInp.setDisabled(disable);
  BlueChannelInp.setDisabled(disable);
  SpecChannelInp.setDisabled(disable);
  DisconnectedChannelInp.setDisabled(disable);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     panelIdentifier="NexgenTeamSpeakConnectorConfigPanel"
     PanelHeight=220.000000
}
