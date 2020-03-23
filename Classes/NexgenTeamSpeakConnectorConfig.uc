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
class NexgenTeamSpeakConnectorConfig extends NexgenPluginConfig;

// Config settings
var config bool bEnabled;               // Whether to enable the plugin or not.
var config bool bInternalDebugging;     // Prints out additional debug logs-lines in the TCP client.
var config float fTimerPeriod;          // Period of the main query timer
var config byte iMode;                  // 0=Single Channel, 1=Multi Channel
var config string TSadress;             // URL of the TS server. IP or Domainname.
var config int TSport;                  // Join port of the TS server. Usually 9987.
var config int TSqueryport;             // Query port of the TS server. Usually 10011.
var config string TSpassword;           // Server password of the TS server (if set).
var config string TSusername;           // Username for querying. Usually 'serveradmin'.
var config string TSuserpassword;       // Password for the respective username.
var config string DefaultChannel;       // Name of the channel for the initial connection.
var config string DefaultChannelpw;     // Pasword of the channel for the initial connection.
var config string MixedChannel;         // Name of the channel for the Mixed Team.
var config string RedChannel;           // Name of the channel for the Red Team.
var config string BlueChannel;          // Name of the channel for the Blue Team.
var config string SpecChannel;          // Name of the channel for the Spectators.
var config string DisconnectedChannel;  // Name of the channel for the Disconnected Players.

/***************************************************************************************************
 *
 *  $DESCRIPTION  Automatically installs the plugin.
 *  $ENSURE       lastInstalledVersion >= xControl.versionNum
 *
 **************************************************************************************************/
function install() {

  if(lastInstalledVersion < 100) installNew();
  else if(lastInstalledVersion < 200) install200();

	lastInstalledVersion = xControl.versionNum;

	// Save updated config or create new one
	saveconfig();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Installs the plugin.
 *
 **************************************************************************************************/
function installNew() {
  TSport              = 9987;
  TSqueryport         = 10011;
  fTimerPeriod        = 1.0;
  iMode               = 0;
  TSusername          = "serveradmin";
  MixedChannel        = "Mixed Channel";
  RedChannel          = "Red Team";
  BlueChannel         = "Blue Team";
  SpecChannel         = "Spectators";
  DisconnectedChannel = "Disconnected Players";
  
  NexgenTeamSpeakConnector(xControl).bJustInstalled = True;
  xControl.control.nscLog("[NexgenTeamSpeakConnectorConfig] Version 200 successfully installed.");
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Installs version 101 of the plugin.
 *
 **************************************************************************************************/
function install200() {
  fTimerPeriod = 1.0;
  iMode = 1;
  xControl.control.nscLog("[NexgenTeamSpeakConnectorConfig] Version 200 successfully installed.");
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
 
defaultproperties
{
}
