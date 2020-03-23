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
class NexgenTeamSpeakConnectorTCP extends UBrowserBufferedTcpLink config(NexgenTeamSpeakConnector);

// Links
var NexgenTeamSpeakConnector xControl;       // Main Plugin Controller.
var NexgenQueue OutputQueue;                 // Output Queue.

// Connection Stages variables
var bool bHandshake;                         // Are we waiting for the initial connection handshake?
var bool bAuthenticating;                    // Whether we are attempting to login.
var bool bSelectingServer;                   // Are we trying to select the right TS server?
var bool bFetchingChannelData;               // Whether we are currently fetching neccessary data.
var bool bInitialized;                       // Initial data collected.
var bool bNextPls;                           // Command finished, ready for next one.

// Misc Variables
var IpAddr ServerIpAddr;                     // The constructed IP info for the TS server.
var int CommandType;                         // Saved info of the last command send.
var string clientID;                         // Saved client ID belonging to the last command.
var int channelAmount;
var int channelIDs[6];                       // Teamspeak's CIDs for each channel.

var string fetchedLine;
var config bool bLogUnescapedNames;

// Constants
const DisconnectMsg="Thank_you_for_visiting!"; // Message displayed after Disconnecting.

/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the TCP Link. Tries to establish a connection to the TS server.
 *
 **************************************************************************************************/
function PreBeginPlay() {
	
	xControl = NexgenTeamSpeakConnector(Owner);
	if(xControl == none) {
  	log("["$self.class$"] Controller not found! Destroying ...");
  	destroy();
  } else {
    if(xControl.iModeInitial == 0) channelAmount = 1;
    else channelAmount = ArrayCount(channelIDs); 
  
  	OutputQueue = spawn(class'NexgenQueue', self);
	
  	LinkMode=MODE_Line;
	
	  outputLog(0, "Establishing connection to TeamSpeak 3 server ...");
	  
  	Resolve(NexgenTeamSpeakConnectorConfig(xControl.xConf).TSadress);
  }
}

/***************************************************************************************************
 *
 *  TCP LINK EVENTS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Event call when the TS adress was successfully resolved to an IP adress.
 *  $PARAM Addr   The resolved IP Adress.
 *
 **************************************************************************************************/
event Resolved(IpAddr Addr) {
	// Set the address
	ServerIpAddr.Addr = Addr.Addr;
	ServerIpAddr.Port = NexgenTeamSpeakConnectorConfig(xControl.xConf).TSqueryport;

	if(ServerIpAddr.Addr == 0 ) {
		outputLog(2, "Invalid server address.");
	} else DoBind();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Event call when the TS adress was not successfully resolved.
 *
 **************************************************************************************************/
event ResolveFailed() {
  outputLog(2, "Resolving failed!");
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Event call when a connection was successfully established with the TS server.
 *
 **************************************************************************************************/
event Opened() {
  outputLog(1, "Connection opened. Shaking Hands ...");
  bHandshake = True;
  Enable('Tick');
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Event call when the connection attempt failed.
 *
 **************************************************************************************************/
event openFailed() {
  outputLog(2, "Opening Connection failed!");
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Event call when the connection closes.
 *
 **************************************************************************************************/
event Closed() {
  outputLog(2, "TeamSpeak 3 server closed the connection!");
  if(bHandshake) {
    outputLog(0, "Make sure you are using the right server adress and ports!");
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Main input function. Receives answers from the TS server.
 *  $PARAM  Line  The answer from the TS server.
 *
 **************************************************************************************************/
event ReceivedLine(string Line) {
  local NexgenTeamSpeakConnectorClient xClient;
  local string substring;
  local int tempCID, tempCLID;
  local int currChannel;

  outputLog(1, "ReceivedLine:"@Line);
  
  if(InStr(Line, "id=3329") != -1 || InStr(Line, "id=3331") != -1) {
    outputLog(2, "Teamspeak Server denied the connection.");
    outputLog(0, "Is the gameserver IP adress in the Teamspeak server's query_ip_whitelist.txt file?");
    bHandshake = False;
    Close();
  } else if(InStr(Line, "id=2568") != -1) {
    outputLog(2, "Operation failed! You don't have the neccessary permissions to perform this action.");
    outputLog(0, "Adjust the permissions for the TeamSpeak Server account "$NexgenTeamSpeakConnectorConfig(xControl.xConf).TSusername$" or use a different account.");
    Close();
  } else if(bHandshake) {
    if(InStr(Line, "Welcome to the TeamSpeak 3 ServerQuery interface") != -1) {
      Handshaken();
    } else if(InStr(Line, "TS3") != -1) return;
    else {
      outputLog(2, "Handshake failed! Received data:"@line);
      outputLog(0, "Make sure you are using the right server adress and ports!");
      Close();
    }
    bHandshake = False;
  } else if(bAuthenticating) {
    if(InStr(Line, "msg=ok") != -1) {
      Authenticated();
    } else if(InStr(Line, "id=520") != -1) {
      outputLog(2, "Authenticating failed! Incorrect username or password.");
      Close();
    } else {
      outputLog(2, "Authenticating failed! Received data:"@line);
      Close();
    }
    bAuthenticating = False;
  } else if(bSelectingServer) {
    if(InStr(Line, "msg=ok") != -1) {
      ServerSelected();
    } else if(InStr(Line, "id=1024") != -1) {
      outputLog(2, "Server selecting failed! No Teamspeak server with port"@NexgenTeamSpeakConnectorConfig(xControl.xConf).TSport$" found.");
      Close();
    } else {
      outputLog(2, "Server selecting failed! Received data:"@line);
      Close();
    }
    bSelectingServer = false;
  } else if(bFetchingChannelData) {
    fetchedLine = fetchedLine$Line;
    if(InStr(Line, "msg=ok") != -1) {
      for(currChannel=0; currChannel<channelAmount; currChannel++) {
        tempCID = getCIDCLID(0, fetchedLine, xControl.ChannelName(currChannel));
        if(tempCID > 0) channelIDs[currChannel] = tempCID;
        else if(tempCID == -1) outputLog(2, "Channel ID: "$currChannel$", Name: "$xControl.ChannelName(currChannel)$" not found!");
      }
      bFetchingChannelData = False;
      ChannelDataFetched();
    } 
  } else if(commandType > 0) {
    if(commandType == 1) {
      fetchedLine = fetchedLine$Line;
      if(InStr(Line, "msg=ok") != -1) {
        outputLog(1, "Query results received.");
        xControl.resetQueryData();
        for(currChannel=0; currChannel<channelAmount; currChannel++) {
          getClientData(currChannel, fetchedLine);
        }
        xControl.queryDataReceived();
        newCommand();
      }
      return;
    }
    
    xClient = getClient();
    if(xClient == none) {
      newCommand();
      return;
    }
    switch(CommandType) {
      case 2:
        if(InStr(Line, "msg=ok") != -1 || InStr(Line, "error id=770") != -1) {
          xClient.SwitchSuccessful();
        } else if(InStr(Line, "error id=768") != -1 || InStr(Line, "error id=512") != -1) {
          xClient.SwitchFailed();
          outputLog(1, "Channel switch failed. Data:"@line);
        } else {
          outputLog(1, "Unknown data received. Commandtype: 2 Data:"@line);
        }
        newCommand();
      break;
      case 3:
        if(InStr(Line, "msg=ok") == -1) {
          outputLog(1, "Unknown data received. Commandtype: 3 Data:"@line);
        }
        newCommand();
      break;
    }
  }
}

/***************************************************************************************************
 *
 *  TCP LINK FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Tries to establish a connection to the TS server.
 *
 **************************************************************************************************/
function DoBind() {
  local int boundPort;

	boundPort = BindPort();
	if(boundPort == 0) {
		outputLog(2, "Error binding local port.");
		return;
	}

	if(!Open(ServerIpAddr)) openFailed();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a line to the Output Queue.
 *  $PARAM Text  The string which is added.
 *
 **************************************************************************************************/
function SendBufferedData(string Text) {
	OutputQueue.enqueue(Text);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Tick function. Calls the DoBufferQueueIO() function.
 *
 **************************************************************************************************/
function Tick(float DeltaTime) {
	Super.Tick(DeltaTime);
	DoBufferQueueIO();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Handles the input/output buffers. Main function in super class, with additional
 *                support for the output Queue.
 *
 **************************************************************************************************/
function DoBufferQueueIO() {
  if(OutputBuffer == "" && !OutputQueue.empty() && bNextPls) {
    OutputBuffer = OutputQueue.front();
    OutputQueue.dequeue();

    if(bInitialized) {
      if(InStr(OutputBuffer, "clientlist") == -1) {
        commandType=int(Left(OutputBuffer, 1));
        clientID = Mid(OutputBuffer, 1, 32);
        OutputBuffer = Mid(OutputBuffer, 33);
      } else commandType = 1;
    }
    outputLog(1, "OutputBuffer is"@OutputBuffer);
    bNextPls=False;
  }
  super.DoBufferQueueIO();
}

/***************************************************************************************************
 *
 *  INITIALIZATION CALLS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Function call when the Handshake was Successful. Proceeds with authenticating in.
 *
 **************************************************************************************************/
function Handshaken() {
  outputLog(1, "Handshaken with Teamspeak Server.");
  outputLog(1, "Authenticating ...");
  bAuthenticating = True;
  SendBufferedData("login "$NexgenTeamSpeakConnectorConfig(xControl.xConf).TSusername$" "$NexgenTeamSpeakConnectorConfig(xControl.xConf).TSuserpassword);
  newCommand();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Function call when the Authentication was Successful. Proceeds with server
 *                selecting.
 *
 **************************************************************************************************/
function Authenticated() {
  outputLog(1, "Successfully authenticated.");
  outputLog(1, "Selecting Server ...");
  bSelectingServer = True;
  SendBufferedData("use port="$NexgenTeamSpeakConnectorConfig(xControl.xConf).TSport);
  newCommand();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Function call when the Server Selection was Successful. Proceeds with channel
 *                data fetching.
 *
 **************************************************************************************************/
function ServerSelected() {
  outputLog(1, "Server selected.");
  outputLog(1, "Fetching channel data ...");
  bFetchingChannelData = True;
  SendBufferedData("channellist");

  newCommand();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Function call when the Channel Data fetching was Successful. Starts normal
 *                command operation mode.
 *
 **************************************************************************************************/
function ChannelDataFetched() {
  local int i;
  local int channelAmount;
  
  outputLog(1, "Channel data fetched.");
  
  if(xControl.iModeInitial == 0) channelAmount = 1;
  else channelAmount = ArrayCount(channelIDs); 
  
  for(i=0; i<channelAmount; i++) {
    outputLog(1, "Channel ID for entry "$i$" is"@channelIDs[i]);
  }
  
  outputLog(0, "Initial connection established and ready for use.");
 
  newCommand();
  bInitialized = True;
}

/***************************************************************************************************
 *
 *  NORMAL OPERATION OUTPUT FUNCTIONS
 *
 **************************************************************************************************/
 
/***************************************************************************************************
 *
 *  $DESCRIPTION  TCP function to get a list of all clients with additional info
 *
 ***************************************************************************************************/ 
function queryChannel() {
  if(bInitialized) {
    SendBufferedData("clientlist -country -voice");
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  TCP function to change a player's channel on the TS server.
 *  $PARAM client The specific client.
 *
 **************************************************************************************************/
function ChangeChannel(NexgenTeamSpeakConnectorClient client, int newChannel) {
  SendBufferedData("2"$client.client.playerID$"clientmove clid="$client.TSclid$" cid="$channelIDs[newChannel]);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  TCP function to kick a player from the TS server.
 *  $PARAM client The specific client.
 *
 **************************************************************************************************/
function Disconnect(NexgenTeamSpeakConnectorClient client) {
  SendBufferedData("3"$client.client.playerID$"clientkick clid="$client.TSclid$" reasonid=5 reasonmsg="$DisconnectMsg);
}

/***************************************************************************************************
 *
 *  MISC FUNCTIONS
 *
 **************************************************************************************************/
/***************************************************************************************************
 *
 *  $DESCRIPTION  Preperes the system to send a new command.
 *
 **************************************************************************************************/
function newCommand() {
  clientID = "";
  fetchedLine = "";
  commandType = -1;
  bNextPls = True;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the specific NexgenTeamSpeakConnectorClient for the current saved clientID.
 *  $RETURN       The specific NexgenTeamSpeakConnectorClient or none.
 *
 **************************************************************************************************/
function NexgenTeamSpeakConnectorClient getClient() {
  local NexgenClient client;
  local NexgenTeamSpeakConnectorClient xClient;

  client = xControl.control.getClientByID(clientID);
  if(client != none) xClient = NexgenTeamSpeakConnectorClient(xControl.getXClient(client));

  return xClient;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the specific NexgenTeamSpeakConnectorClient for the current saved clientID.
 *  $PARAM logType 0=NormalOutputLog, 1=DebugLog, 2=ErrorLog
 *
 **************************************************************************************************/
function outputLog(int logType, string logMsg) {
  switch(logType) {
    case 0: xControl.control.nscLog("[NexgenTeamSpeakConnectorTCP]"@logMsg); break;
    case 1: if(NexgenTeamSpeakConnectorConfig(xControl.xConf).bInternalDebugging) {
              xControl.control.nscLog("[NexgenTeamSpeakConnectorTCP] [DEBUG LOG]"@logMsg);
            }
            break;
    case 2: xControl.control.nscLog("[NexgenTeamSpeakConnectorTCP] [ERROR]"@logMsg); break;
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Finds the belonging CLID for the client.
 *  $PARAM Line The result output of the TS server.
 *  $PARAM xClient The client we are looking for.
 *  $RETURN The specific CLID.
 *
 **************************************************************************************************/
function int getCIDCLID(int mode, string Line, string compareString) {
  local string results[128];
  local string remaining, namestring;
  local string searchString1, searchString2, searchString3, searchString4, searchString5;
  local int pos, currResult;
  local int i;
  local int firstFound, specialChannel;
  
  if(compareString == "") return -1;

  remaining = Line;

  while(remaining != "" && currResult < ArrayCount(results)) {
    pos = InStr(remaining, "|");
    if(pos != -1) {
      results[currResult] = Left(remaining, pos);
      remaining = Mid(remaining, pos+1);
    } else {
      results[currResult] = remaining;
      remaining = "";
    }
    currResult++;
  }
  
  switch(mode) {
    case 0:
      searchString1 = " channel_name=";
      searchString2 = "cid=";
      searchString3 = " total_clients=";
      searchString4 = " channel_order=";
      searchString5 = " pid=";
    break;
    case 1:
      searchString1 = " client_nickname=";
      searchString2 = "clid=";
      searchString3 = " client_type=";
      searchString4 = " client_database_id=";
      searchString5 = " cid=";
    break;
  }
  
  firstFound = -1;

  for(i=0; i<CurrResult; i++) {
    namestring = Mid(results[i], InStr(results[i], searchString1)+Len(searchString1));
    
    if(unescapeName(Left(namestring, InStr(namestring, searchString3))) == compareString) {
      if(mode == 1 || firstFound == -1) firstFound = int(Mid(Left(results[i], InStr(results[i], searchString5)), Len(searchString2)));
      if(channelIDs[0] > 0) {
        specialChannel = int(Mid(Left(results[i], InStr(results[i], searchString4)), InStr(results[i], searchString5)+Len(searchString5)));
        
        if(mode == 0 && specialChannel == channelIDs[0]) return int(Mid(Left(results[i], InStr(results[i], searchString5)), Len(searchString2)));
        else if(mode == 1) {
          if(specialChannel == channelIDs[0] || specialChannel == channelIDs[1] || specialChannel == channelIDs[2] ||
            specialChannel == channelIDs[3] || specialChannel == channelIDs[4] || specialChannel == channelIDs[5]) {
            return firstFound;
          } else return -1;
        }
      } else if(mode == 1) return firstFound;
    }
  }
  return firstFound;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Finds the belonging CLID for the client.
 *  $PARAM Line The result output of the TS server.
 *  $PARAM xClient The client we are looking for.
 *  $RETURN The specific CLID.
 *
 **************************************************************************************************/
function getClientData(int currChannel, string Line) {
  local int cid;
  local string results[128];
  local string remaining, clidstring, namestring, countrystring; 
  local byte talkingflag, hardwareflag, mutedflag;
  local string searchString0, searchString1, searchString2, searchString3, searchString4, searchString5;
  local int pos, currResult;
  local int i;

  cid = channelIDs[currChannel];
  remaining = Line;
  
  outputLog(1, "getClientData for channel "$currChannel$" with Line="$Line);

  while(remaining != "" && currResult < ArrayCount(results)) {
    pos = InStr(remaining, "|");
    if(pos != -1) {         
      if(InStr(Left(remaining, pos), "cid="$cid$" ") != -1) {
        results[currResult] = Left(remaining, pos);
        currResult++;
      }
      remaining = Mid(remaining, pos+1);
    } else {
      if(InStr(remaining, "cid="$cid) != -1) {
        results[currResult] = Left(remaining, InStr(remaining, "error id=")-2);
        currResult++;
      }
      remaining = "";
    }
  }
  
  searchString0 = "clid=";
  searchString1 = "client_nickname=";
  searchString2 = "client_flag_talking=";
  searchString3 = "client_input_muted=";
  searchString4 = "client_input_hardware=";
  searchString5 = "client_country=";
  
  if(channelAmount == 1) currChannel = 1;

  for(i=0; i<CurrResult && xControl.tsQueryDataIndex < ArrayCount(xControl.tsChanID); i++) {
    clidstring    = Mid(results[i], InStr(results[i], searchString0)+Len(searchString0) );
    clidstring    = Left(clidstring, InStr(clidstring, " "));
    namestring    = Mid(results[i], InStr(results[i], searchString1)+Len(searchString1) );
    namestring    = unescapeName(Left(namestring, InStr(namestring, " client_type=")));
    talkingflag   = byte(Mid(results[i], InStr(results[i], searchString2)+Len(searchString2), 1));
    mutedflag     = byte(Mid(results[i], InStr(results[i], searchString3)+Len(searchString3), 1));
    hardwareflag  = byte(Mid(results[i], InStr(results[i], searchString4)+Len(searchString4), 1));
    countrystring = Mid(results[i], InStr(results[i], searchString5)+Len(searchString5));
	
    xControl.tsChanID  [xControl.tsQueryDataIndex] = currChannel;
    xControl.tsClientID[xControl.tsQueryDataIndex] = clidstring;
    xControl.tsName    [xControl.tsQueryDataIndex] = namestring;
    xControl.tsFlags   [xControl.tsQueryDataIndex] = talkingflag*1 + mutedflag*2 + hardwareflag*4;
    xControl.tsCountry [xControl.tsQueryDataIndex] = countrystring;
    xControl.tsQueryDataIndex++;
    
    outputLog(1, namestring$", " $talkingflag$ ", " $ mutedflag$ ", " $hardwareflag$ ", " $countrystring);
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Finds the belonging CLID for the client.
 *  $PARAM escapedName The escaped channel/player name sent by the TS server.
 *  $RETURN The unescaped, UT-readable name.
 *
 **************************************************************************************************/
function string unescapeName(string escapedName) {
  local string unescapedName;
  
  unescapedName = escapedName;
  
  unescapedName = class'NexgenUtil'.static.replace(unescapedName, "\\s", " ");
  unescapedName = class'NexgenUtil'.static.replace(unescapedName, "\\/", "/");
  
  if(bLogUnescapedNames) outputLog(1, "Unescaped name is:"@unescapedName);
  
  return unescapedName;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
 
defaultproperties
{
     RemoteRole=ROLE_None
}
