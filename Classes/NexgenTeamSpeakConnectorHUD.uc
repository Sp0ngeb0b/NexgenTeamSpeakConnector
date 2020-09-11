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
class NexgenTeamSpeakConnectorHUD extends Mutator;

var NexgenTeamSpeakConnectorClient xClient;                  // The client that is displaying the player list.

var NexgenHUD NHUD;

var color blankColor;                   // White color (#FFFFFF).
var color TeamColor[6];                 // Player colors per rank.
var Texture tsFlagsTex[3];

var bool bEnabled; 
var bool forceHidden;
var bool bRenderingHud;

const NSVHUDDuration = 9.5;         

var font baseFont;                      // The font used to render the player lists.
var float baseFontHeight;               // Height of the used font.

const flagNormalWidth = 16.0;           // Normal width of the flag textures.
const flagNormalHeight = 16.0;          // Noraml height of the flag textures.
const lineDistance = 1;                 // Distance between lines.
const columnDistance = 4;               // Distance between columns.
const borderSize = 16;                  // Border size of the player list window.

/***************************************************************************************************
 *
 *  $DESCRIPTION  Command interface function. Can be used by other mods to query the status of the
 *                the client list visibility and to hide or show it. Supported commands:
 *                show    Shows the stats list.
 *                hide    Hides the stats list.
 *                status  Returns "show" if the list is shown, and "hide" if it isn't visible.
 *  $PARAM        cmd  The command to execute.
 *  $RETURN       Result of the command.
 *
 **************************************************************************************************/
function string getItemName(string cmd) {
	switch(cmd) {
		case "show": // Show the stats.
			forceHidden = false;
			break;
		
		case "hide": // Hide the stats.
			forceHidden = true;
			break;
		
		case "status": // Return visibility status of stats.
			if (!bRenderingHud) {
				return "hide";
			} else {
				return "show";
			}
			break;
	}
	
	return "";
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the statistics HUD.
 *  $REQUIRE      owner != none && owner.isA('NXStatsClient')
 *  $ENSURE       client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function postBeginPlay() {  
	xClient = NexgenTeamSpeakConnectorClient(owner);
  
  forEach AllActors(class'NexgenHUD', NHUD) break;
  
  if(NHUD == None) destroy();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Attemps to register this HUD instance as a HUD mutator.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	// Register as HUD mutator if not already done. Note this may fail several times.
	if (!bHUDMutator) registerHUDMutator();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the TS overlay.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function postRender(Canvas c) {
  local bool displayNSVHud;
  
	// Let other HUD mutators do their job first.
	if (nextHUDMutator != none) {
		nextHUDMutator.postRender(c);
	}
	  
  // For compatibility with NSV
  if(xClient.NSVHUD != None) {
    if(xClient.NSVHUD.getItemName("status") == "show") {
      if(xClient.NSVHUDFound < 0.0) {
        xClient.NSVHUDFound = Level.TimeSeconds;
        displayNSVHud = true;
      } else if(Level.TimeSeconds-xClient.NSVHUDFound > NSVHUDDuration) {
        if(bEnabled && !forceHidden && xClient.clientAmount > 0) xClient.NSVHUD.getItemName("hide");
        displayNSVHud = false;
        xClient.NSVHUDFound = -1;
      } else displayNSVHud = true;
    } else {
      displayNSVHud = false;
      xClient.NSVHUDFound = -1;
    }
  }
	if(bEnabled && !displayNSVHud && !forceHidden) renderTSOverlay(c);
  else bRenderingHud = false;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Sets up the HUD appearance variables.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none && bInitialSetupDone
 *
 **************************************************************************************************/
function renderTSOverlay(Canvas c) {
  local int possibleLines, linesToRender, lineHeight;
  local int startY, endY;
	local int baseY;
	local int cy;
	local byte i;
	local float cw;
  
  bRenderingHud = true;
  
  // Set base variables.
  baseFont = ChallengeHUD(c.viewport.actor.myHUD).myFonts.getStaticSmallestFont(c.clipX);
  c.font = baseFont;
  c.strLen("TEST", cw, baseFontHeight);
  lineHeight = baseFontHeight+lineDistance;

  // Determine possible area
  startY = NHUD.msgBoxHeight + NHUD.msgBoxLineHeight + 2 + NHUD.baseFontHeight*6; // ArrayCount of additional messages is 5 
  endY   = c.clipY-128;
  possibleLines = (endY-startY)/lineHeight;
  
  // How many lines are we going to render
  if(xClient.iMode == 0) linesToRender = xClient.mixedChannelIndex;
  else {      
    linesToRender = xClient.mixedChannelIndex + xClient.redChannelIndex + xClient.blueChannelIndex + xClient.specChannelIndex - 1;  
    if(xClient.mixedChannelIndex > 0) linesToRender++;
    if(xClient.redChannelIndex > 0)   linesToRender++;
    if(xClient.blueChannelIndex > 0)  linesToRender++;
    if(xClient.specChannelIndex > 0)  linesToRender++;
  }
  linesToRender = clamp(linesToRender, 0, possibleLines);
	
	// Determine base position.
	baseY = startY + ((endY-startY)-linesToRender*lineHeight)/2;
	
	// Render client lists.
	c.font = baseFont;
	c.style = ERenderStyle.STY_Normal;

  // Render clients.
  if(xClient.iMode == 0) {
    for (i=0; i < xClient.mixedChannelIndex; i++) drawClient(c, xClient.mixedChannelNames[i], xClient.mixedChannelTeam[i], xClient.mixedChannelFlags[i], baseFontHeight, lineHeight, baseY, endY, cy);
  } else {
    for (i=0; i < xClient.mixedChannelIndex; i++) drawClient(c, xClient.mixedChannelNames[i], 128, xClient.mixedChannelFlags[i], baseFontHeight, lineHeight, baseY, endY, cy);
    if(xClient.mixedChannelIndex > 0)             drawClient(c, "", 128, 0, baseFontHeight, lineHeight, baseY, endY, cy);
    for (i=0; i < xClient.redChannelIndex; i++)   drawClient(c, xClient.redChannelNames[i], 0, xClient.redChannelFlags[i], baseFontHeight, lineHeight, baseY, endY, cy);
    if(xClient.redChannelIndex > 0)               drawClient(c, "", 128, 0, baseFontHeight, lineHeight, baseY, endY, cy);
    for (i=0; i < xClient.blueChannelIndex; i++)  drawClient(c, xClient.blueChannelNames[i], 1, xClient.blueChannelFlags[i], baseFontHeight, lineHeight, baseY, endY, cy);
    if(xClient.blueChannelIndex > 0)              drawClient(c, "", 128, 0, baseFontHeight, lineHeight, baseY, endY, cy);
    for (i=0; i < xClient.specChannelIndex; i++)  drawClient(c, xClient.specChannelNames[i], 255, xClient.specChannelFlags[i], baseFontHeight, lineHeight, baseY, endY, cy);
  }
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders a single line containing a client name and its TS flag.
 *
 **************************************************************************************************/
function drawClient(Canvas c, string clientName, byte clientTeam, byte clientFlag, int baseFontHeight, int lineHeight, int baseY, int endY, out int cy) {
  local int flagHeight, flagWidth;                    
  local int cx, baseX;
  local color lineCol;
  local string shortenedName;
  
  // Scale icon.
  if (flagNormalHeight > baseFontHeight) {
    flagHeight = baseFontHeight;
    flagWidth = baseFontHeight / flagNormalHeight * flagNormalWidth;
  } else {
    flagHeight = flagNormalHeight;
    flagWidth = flagNormalWidth;
  }
  
  if(baseY + cy + lineHeight > endY) return;
  else if(baseY + cy + lineHeight > endY-lineHeight) {
    c.setPos(borderSize + flagWidth + columnDistance, baseY + cy);
    c.drawColor = teamColor[4];
    c.drawText("...", false);
    cy += lineHeight;  
    return;
  }
  
  if(clientName != "") {
    // Determine line color.
    lineCol = getDisplayColor(clientTeam);

    // Render flag.
    baseX = borderSize;
    c.setPos(baseX + cx, baseY + cy + (baseFontHeight - flagHeight) / 2);
    c.drawColor = blankColor;
    c.drawTile(getTsTex(clientFlag), flagWidth, flagHeight, 0.0, 0.0, flagNormalWidth, flagNormalHeight);
      
    cx += flagWidth + columnDistance;
    
    // Render player name.
    c.setPos(baseX + cx, baseY + cy);
    c.drawColor = lineCol;
    if(Len(clientName) >= 20) shortenedName = Left(clientName, 17)$"..."; // TS limits the name length to 30, but we still want to shorten it
    else                      shortenedName = Left(clientName, 20); 
    c.drawText(shortenedName, false);  
  }
  cy += lineHeight;  
} 

/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the color in which the text should be displayed for a client.
 *  $PARAM        item  The item for which its display color has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The color in which the text should be displayed for the specified item.
 *
 **************************************************************************************************/
function color getDisplayColor(byte team) {	
  if(team != 128) {
    if(team > 5) return teamColor[5];
    else return TeamColor[team];
  } else return teamColor[4]; 
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the TS flag texture of the TS client.
 *  $RETURN       A texture of the TS flag of the player.
 *
 **************************************************************************************************/
function texture getTsTex(byte tsFlags) {
  
  if(tsFlags > 3) { // Hardware is available
	  if(tsFlags-4 > 1)	 	    return tsFlagsTex[2];
	  else if(tsFlags-4 == 1) return tsFlagsTex[1];
	  else 			     	        return tsFlagsTex[0];
	} else 				 	          return tsFlagsTex[2]; 
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     blankColor=(R=255,G=255,B=255)
     TeamColor(0)=(R=200,G=20,B=20)
     TeamColor(1)=(R=20,G=20,B=150)
     TeamColor(2)=(R=20,G=200,B=20)
     TeamColor(3)=(R=200,G=150,B=20)
     TeamColor(4)=(R=255,G=255,B=255)
     TeamColor(5)=(R=100,G=100,B=100)
     tsFlagsTex(0)=Texture'notTalking'; 
     tsFlagsTex(1)=Texture'talking';
     tsFlagsTex(2)=Texture'muted';
     bAlwaysTick=True
     RemoteRole=ROLE_None
}