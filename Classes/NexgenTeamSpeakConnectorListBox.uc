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
class NexgenTeamSpeakConnectorListBox extends NexgenPlayerListBox;

var color noGamerColor;

/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the specified listbox item.
 *  $PARAM        c     The canvas object on which the rendering will be performed.
 *  $PARAM        item  Item to render.
 *  $PARAM        x     Horizontal offset on the canvas.
 *  $PARAM        y     Vertical offset on the canvas.
 *  $PARAM        w     Width of the item that is to be rendered.
 *  $PARAM        h     Height of the item that is to be rendered.
 *  $REQUIRE      c != none && item != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function drawItem(Canvas c, UWindowList item, float x, float y, float w, float h) {
	local int offsetX;
	local texture flagTex, tsTex;
	local color backgroundColor;
	
	// Draw background.
	backgroundColor = getBackgroundColor(NexgenPlayerList(item));
	if (backgroundColor != baseColor) {
		c.drawColor = backgroundColor;
		drawStretchedTexture(c, x, y, w, h - 1, Texture'WhiteTexture');
	}
	
	// Draw country flag.
	offsetX = 2;
	if (bShowCountryFlag) {
		c.drawColor = baseColor;
		flagTex = NexgenPlayerList(item).getFlagTex();
		if (flagTex == none) {
			flagTex = texture'noCountry';
		}
		drawClippedTexture(c, x + offsetX, y + 1, flagTex);
		offsetX += 18;
	}
	
  // Draw TS icon.
  c.drawColor = baseColor;
	tsTex = NexgenTeamSpeakConnectorItem(item).getTsTex();
	drawClippedTexture(c, x + offsetX, y + 1, tsTex);
	offsetX += 15;
	
	// Draw text.
	c.drawColor = getDisplayColor(NexgenPlayerList(item));
	c.font = getDisplayFont(NexgenPlayerList(item));
	clipText(c, x + offsetX, y, NexgenPlayerList(item).pName);
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Make items not selectable.
 *
 **************************************************************************************************/
function SetSelectedItem(UWindowListBoxItem NewSelected) {
  return;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Returns the color in which the text should be displayed for a list item.
 *  $PARAM        item  The item for which its display color has to be determined.
 *  $REQUIRE      item != none
 *  $RETURN       The color in which the text should be displayed for the specified item.
 *
 **************************************************************************************************/
function color getDisplayColor(NexgenPlayerList item) {	
  if(item.pTeam != 128) {
    if(item.pTeam > 5) return teamColor[5];
    else return teamColor[item.pTeam];
  } else return noGamerColor; 
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties
{
     ItemHeight=13.000000
     ListClass=Class'NexgenTeamSpeakConnectorItem'
     noGamerColor=(R=0,G=0,B=0);
}