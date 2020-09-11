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
class NexgenTeamSpeakConnectorItem extends NexgenPlayerList;

#exec TEXTURE IMPORT NAME=notTalking FILE=Resources\notTalking.pcx GROUP="GFX" FLAGS=3 MIPS=On
#exec TEXTURE IMPORT NAME=talking    FILE=Resources\talking.pcx GROUP="GFX"    FLAGS=3 MIPS=On
#exec TEXTURE IMPORT NAME=muted 	   FILE=Resources\muted_red.pcx GROUP="GFX"  FLAGS=3 MIPS=On

var byte    tsFlags;
var texture tsTex;          // Texture for the TS flag.

/***************************************************************************************************
 *
 *  $DESCRIPTION  Retrieves the TS flag texture of the TS client.
 *  $RETURN       A texture of the TS flag of the player.
 *
 **************************************************************************************************/
function texture getTsTex() {
    if(tsFlags > 3) { // Hardware is available
	  if(tsFlags-4 > 1)	 	    tsTex = Texture'muted'; 
	  else if(tsFlags-4 == 1) tsTex = Texture'talking'; 
	  else 			     	        tsTex = Texture'notTalking'; 
	} else 				 	          tsTex = Texture'muted'; 

	return tsTex;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Compares two UWindowList items.
 *  $PARAM        a  First item to compare.
 *  $PARAM        b  Second item to compare.
 *  $REQUIRE      a != none && b != none
 *  $RETURNS      -1 If the first item is 'smaller' then the second item, otherwise 1 is returned.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function int compare(UWindowList a, UWindowList b) {
	if (NexgenTeamSpeakConnectorItem(a).pName < NexgenTeamSpeakConnectorItem(b).pName) {
		return -1;
	} else {
		return 1;
	}
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
     pNum=-1
}