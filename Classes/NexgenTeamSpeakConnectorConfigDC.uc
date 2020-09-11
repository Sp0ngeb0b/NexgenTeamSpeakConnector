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
class NexgenTeamSpeakConnectorConfigDC extends NexgenSharedDataContainer;

var NexgenTeamSpeakConnectorConfig xConf;

var bool bEnabled;
var bool bInternalDebugging;
var float fTimerPeriod;
var byte iMode;
var string TSadress;
var int TSport;
var int TSqueryport;
var string TSpassword;
var string TSusername;
var string TSuserpassword;
var string DefaultChannel;
var string DefaultChannelpw;
var string MixedChannel;
var string RedChannel;
var string BlueChannel;
var string SpecChannel;
var string DisconnectedChannel;

/***************************************************************************************************
 *
 *  $DESCRIPTION  Loads the data that for this shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function loadData() {
	local int index;

	xConf = NexgenTeamSpeakConnectorConfig(xControl.xConf);

	bEnabled            = xConf.bEnabled;
	bInternalDebugging  = xConf.bInternalDebugging;
  fTimerPeriod        = xConf.fTimerPeriod;
  iMode               = xConf.iMode;
	TSadress            = xConf.TSadress;
	TSport              = xConf.TSport;
	TSqueryport         = xConf.TSqueryport;
	TSpassword          = xConf.TSpassword;
	TSusername          = xConf.TSusername;
	TSuserpassword      = xConf.TSuserpassword;
	DefaultChannel      = xConf.DefaultChannel;
	DefaultChannelpw    = xConf.DefaultChannelpw;
	MixedChannel        = xConf.MixedChannel;
	RedChannel          = xConf.RedChannel;
	BlueChannel         = xConf.BlueChannel;
	SpecChannel         = xConf.SpecChannel;
	DisconnectedChannel = xConf.DisconnectedChannel;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Saves the data stored in this shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function saveData() {
	xConf.saveConfig();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION Overwrites original function so that only admins receive the initial info.
 *               (optimizes network performance)
 *
 **************************************************************************************************/
function initRemoteClient(NexgenExtendedClientController xClient) {
  if(!xClient.client.hasRight(xClient.client.R_ServerAdmin)) return;
  super.initRemoteClient(xClient);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Changes the value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be changed.
 *  $PARAM        value    New value for the variable.
 *  $PARAM        index    Array index in case the variable is an array.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $OVERRIDE
 *
 **************************************************************************************************/
function set(string varName, coerce string value, optional int index) {
	switch (varName) {
	  case "bEnabled":             bEnabled            = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.bEnabled             = bEnabled;            } break;
    case "bInternalDebugging":   bInternalDebugging  = class'NexgenUtil'.static.str2bool(value); if (xConf != none) { xConf.bInternalDebugging   = bInternalDebugging;  } break;
    case "fTimerPeriod":         fTimerPeriod        = fclamp(float(value), 0.2, 5.0);            if (xConf != none) { xConf.fTimerPeriod         = fTimerPeriod;        } break;
    case "iMode":                iMode               = clamp(int(value), 0, 1);                  if (xConf != none) { xConf.iMode                = iMode;               } break;
    case "TSadress":             TSadress            = value;                                    if (xConf != none) { xConf.TSadress             = TSadress;            } break;
    case "TSport":               TSport              = clamp(int(value), 0, 66535);              if (xConf != none) { xConf.TSport               = TSport;              } break;
    case "TSqueryport":          TSqueryport         = clamp(int(value), 0, 66535);              if (xConf != none) { xConf.TSqueryport          = TSqueryport;         } break;
    case "TSpassword":           TSpassword          = value;                                    if (xConf != none) { xConf.TSpassword           = TSpassword;          } break;
    case "TSusername":           TSusername          = value;                                    if (xConf != none) { xConf.TSusername           = TSusername;          } break;
    case "TSuserpassword":       TSuserpassword      = value;                                    if (xConf != none) { xConf.TSuserpassword       = TSuserpassword;      } break;
    case "DefaultChannel":       DefaultChannel      = value;                                    if (xConf != none) { xConf.DefaultChannel       = DefaultChannel;      } break;
    case "DefaultChannelpw":     DefaultChannelpw    = value;                                    if (xConf != none) { xConf.DefaultChannelpw     = DefaultChannelpw;    } break;
    case "MixedChannel":         MixedChannel        = value;                                    if (xConf != none) { xConf.MixedChannel         = MixedChannel;        } break;
    case "RedChannel":           RedChannel          = value;                                    if (xConf != none) { xConf.RedChannel           = RedChannel;          } break;
    case "BlueChannel":          BlueChannel         = value;                                    if (xConf != none) { xConf.BlueChannel          = BlueChannel;         } break;
    case "SpecChannel":          SpecChannel         = value;                                    if (xConf != none) { xConf.SpecChannel          = SpecChannel;         } break;
    case "DisconnectedChannel":  DisconnectedChannel = value;                                    if (xConf != none) { xConf.DisconnectedChannel  = DisconnectedChannel; } break;
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to read the variable value.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $PARAM        varName  Name of the variable whose access is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable may be read by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mayRead(NexgenExtendedClientController xClient, string varName) {

  return xClient.client.hasRight(xClient.client.R_ServerAdmin);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to change the variable value.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $PARAM        varName  Name of the variable whose access is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable may be changed by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool mayWrite(NexgenExtendedClientController xClient, string varName) {
  return xClient.client.hasRight(xClient.client.R_ServerAdmin);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified client is allowed to save the data in this container.
 *  $PARAM        xClient  The controller of the client that is to be checked.
 *  $REQUIRE      xClient != none
 *  $RETURN       True if the data may be saved by the specified client, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool maySaveData(NexgenExtendedClientController xClient) {
	return xClient.client.hasRight(xClient.client.R_ServerAdmin);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the boolean value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The boolean value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool getBool(string varName, optional int index) {
	switch (varName) {
		case "bEnabled":           return bEnabled;
		case "bInternalDebugging": return bInternalDebugging;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the byte value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The byte value of the specified variable.
 *
 **************************************************************************************************/
function byte getByte(string varName, optional int index) {
	switch (varName) {
		case "iMode": return iMode;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the integer value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The integer value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getInt(string varName, optional int index) {
	switch (varName) {
		case "TSport":       return TSport;
		case "TSqueryport":  return TSqueryport;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the float value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The float value of the specified variable.
 *
 **************************************************************************************************/
function float getFloat(string varName, optional int index) {
	switch (varName) {
		case "fTimerPeriod": return fTimerPeriod;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Reads the string value of the specified variable.
 *  $PARAM        varName  Name of the variable whose value is to be retrieved.
 *  $PARAM        index    Index of the element in the array that is to be retrieved.
 *  $REQUIRE      varName != "" && imply(isArray(varName), 0 <= index && index <= getArraySize(varName))
 *  $RETURN       The string value of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getString(string varName, optional int index) {
	switch (varName) {
		case "bEnabled":            return string(bEnabled);
		case "bInternalDebugging":  return string(bInternalDebugging);
    case "fTimerPeriod":        return string(fTimerPeriod);
    case "iMode":               return string(iMode);
		case "TSadress":            return TSadress;
		case "TSport":              return string(TSport);
		case "TSqueryport":         return string(TSqueryport);
		case "TSpassword":          return TSpassword;
		case "TSusername":          return TSusername;
		case "TSuserpassword":      return TSuserpassword;
		case "DefaultChannel":      return DefaultChannel;
		case "DefaultChannelpw":    return DefaultChannelpw;
		case "MixedChannel":        return MixedChannel;
		case "RedChannel":          return RedChannel;
		case "BlueChannel":         return BlueChannel;
		case "SpecChannel":         return SpecChannel;
		case "DisconnectedChannel": return DisconnectedChannel;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the number of variables that are stored in the container.
 *  $RETURN       The number of variables stored in the shared data container.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getVarCount() {
	return 17;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the variable name of the variable at the specified index.
 *  $PARAM        varIndex  Index of the variable whose name is to be retrieved.
 *  $REQUIRE      0 <= varIndex && varIndex <= getVarCount()
 *  $RETURN       The name of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function string getVarName(int varIndex) {
	switch (varIndex) {
		case 0:  return "bEnabled";
		case 1:  return "bInternalDebugging";
    case 2:  return "fTimerPeriod";
    case 3:  return "iMode";
		case 4:  return "TSadress";
		case 5:  return "TSport";
		case 6:  return "TSqueryport";
		case 7:  return "TSpassword";
		case 8:  return "TSusername";
		case 9:  return "TSuserpassword";
		case 10: return "DefaultChannel";
		case 11: return "DefaultChannelpw";
		case 12: return "MixedChannel";
		case 13: return "RedChannel";
		case 14: return "BlueChannel";
		case 15: return "SpecChannel";
		case 16: return "DisconnectedChannel";
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the data type of the specified variable.
 *  $PARAM        varName  Name of the variable whose data type is to be retrieved.
 *  $REQUIRE      varName != ""
 *  $RETURN       The data type of the specified variable.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function byte getVarType(string varName) {
	switch (varName) {
		case "bEnabled":            return DT_BOOL;
		case "bInternalDebugging":  return DT_BOOL;
    case "fTimerPeriod":        return DT_FLOAT;
    case "iMode":               return DT_BYTE;
		case "TSadress":            return DT_STRING;
		case "TSport":              return DT_INT;
		case "TSqueryport":         return DT_INT;
		case "TSpassword":          return DT_STRING;
		case "TSusername":          return DT_STRING;
		case "TSuserpassword":      return DT_INT;
		case "DefaultChannel":      return DT_STRING;
		case "DefaultChannelpw":    return DT_STRING;
		case "MixedChannel":        return DT_STRING;
		case "RedChannel":          return DT_STRING;
		case "BlueChannel":         return DT_STRING;
		case "SpecChannel":         return DT_STRING;
		case "DisconnectedChannel": return DT_STRING;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the array length of the specified variable.
 *  $PARAM        varName  Name of the variable which is to be checked.
 *  $REQUIRE      varName != "" && isArray(varName)
 *  $RETURN       The size of the array.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int getArraySize(string varName) {
	switch (varName) {
		default:				           return 0;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Checks whether the specified variable is an array.
 *  $PARAM        varName  Name of the variable which is to be checked.
 *  $REQUIRE      varName != ""
 *  $RETURN       True if the variable is an array, false if not.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function bool isArray(string varName) {
	switch (varName) {
		default: return false;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     containerID="NexgenTeamSpeakConnector_config"
}
