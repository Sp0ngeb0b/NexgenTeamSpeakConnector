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
class NexgenTeamSpeakConnectorGuide extends NexgenPopupDialog;

/***************************************************************************************************
 *
 *  $DESCRIPTION  Creates the dialog. Calling this function will setup the static dialog contents.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function created() {
	local float cy;

	super.created();

	// Add components.
	cy = borderSize;

	addDynamicTextArea();
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Adds a new dynamic text area control component to the current region.
 *  $REQUIRE      0 <= currRegion && currRegion < regionCount
 *  $RETURN       The dynamic text area control that has been added to the panel.
 *  $ENSURE       result != none
 *
 **************************************************************************************************/
function UWindowDynamicTextArea addDynamicTextArea() {
	local UMenuMapListFrameCW frame;
	local UWindowDynamicTextArea textArea;
	local string GuideText;

	frame = UMenuMapListFrameCW(createWindow(class'UMenuMapListFrameCW', buttonPanelBorderSize, 0, winWidth - 0.5 * borderSize, winHeight - buttonPanelHeight - buttonPanelBorderSize - 4));
	textArea = UWindowDynamicTextArea(CreateControl(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	textArea.setTextColor(lookAndFeel.editBoxTextColor);
  textArea.bTopCentric = false;
	frame.frame.setFrame(textArea);
	textArea.bTopCentric = True;
	
	// Begin Guide
	textArea.AddText("Nexgen TeamSpeak Connector (NTSC)");
	textArea.AddText("Version"@Class'NexgenTeamSpeakConnector'.default.pluginVersion);
	textArea.AddText("(C) 2019 Patrick 'Sp0ngeb0b' Peltzer");
	textArea.AddText("");
	textArea.AddText("");
	textArea.AddText("USER MANUAL");
	textArea.AddText("");
	textArea.AddText("To use this mod, the Teamspeak 3 Client needs to be installed on your computer. You can download it for a selection of operating system for FREE from their official site:");
  textArea.AddText("");
  textArea.AddText("http://www.teamspeak.com/?page=downloads");
  textArea.AddText("");
  GuideText = "Follow the install instructions to set it up correctly. No further information or support is provided on this matter,as it is not related to this plugin.";
  GuideText = GuideText@"If you need help, look on their homepage or post in the TS forum.";
  textArea.AddText(GuideText);
  textArea.AddText("");
  textArea.AddText("The following manual assumes that you have installed and configured Teamspeak 3 correctly.");
  textArea.AddText("");
  GuideText = "As soon as you are connected to a UT99 gameserver running this plugin, you will find the NTSC in-game tab in Nexgen. Say '!open' to bring up the Nexgen window and click on the tab 'Teamspeak' on the upper end of the window.";
  GuideText = GuideText@"Alternatively, you can directly bring up the tab by saying '!ts'.";
  textArea.AddText(GuideText);
  textArea.AddText("");
  GuideText = "Depending on the gameserver's configuration, you'll either see a single list or 4 lists on the left half of the tab, and 3 panels on the right half.";
  GuideText = GuideText@"The former are the live channel query lists and display the current players connected to the TS server in their respective channel.";
  GuideText = GuideText@"Additional teamspeak flags are displayed as an icon to indicate standby, speaking, muted microphone or no microphone.";
  textArea.AddText(GuideText);
  textArea.AddText("");
  GuideText = "The first panel on the right allows you to control your connection to the TS server. By clicking the button 'Connect', it will start up your Teamspeak 3 Client and lets it connect to the gameserver's specific Teamspeak server.";
  GuideText = GuideText@"NOTE: UT may minimize during this process. You can either switch back to UT manually, or use the setting 'Connect in windowed Mode' (see further below for more info).";
  GuideText = GuideText@"Your OS may open up a window asking which program to use. If so, continue by selecting the Teamspeak 3 Client in the pop up window and click OK. If setup right, your Teamspeak 3 Client will start up now and automatically connect to the Teamspeak server.";
  GuideText = GuideText@"If the server is configured to use a single channel, you automatically enter it on join. Otherwise, NTSC will move you to your desired channel according to your 'Default TS Channel' setting.";
  textArea.AddText(GuideText);
  textArea.AddText("Hint: You can perform this action quickly by saying '!tsjoin'.");
  textArea.AddText("");
  GuideText = "Clicking the 'Disconnect' button will close your connection to the TS server. Teamspeak will tell you that you have been kicked from the server - don't worry, that's how it's supposed to be and you are neither kicked or banned for good.";
  textArea.AddText(GuideText);
  textArea.AddText("Hint: You can perform this action quickly by saying '!tsleave'.");
  textArea.AddText("");
  textArea.AddText("'Change Channel' - as the name suggests, this button allows you to switch between the Mixed Channel and your specifc Team Channel if the server is configured to use multi channels.");
  textArea.AddText("Hint: You can perform this action quickly by saying '!tsswitch'.");
  textArea.AddText("");
  GuideText = "Underneath the Control panel you'll find 5 personal client-settings to optimize your Teamspeak experience:";
  textArea.AddText(GuideText);
  textArea.AddText("");
  GuideText = Chr(187)$Chr(187)$" The first setting, called 'Auto connect to TS on join', will automatically run the 'Connect' action after joined the gameserver if you are not connected to TS yet.";
  textArea.AddText(GuideText);
  GuideText = Chr(187)$Chr(187)$" 'Connect in windowed mode' is relevant when your client initially connects to the TS server. UT will minimize during this process. However, you can minimize the impact on your gameplay by enabling this option:";
  GuideText = GuideText@"As soon as you press the 'Connect' button, UT will switch to windowed mode, preventing the game from minimizing completely and allows you to still take part in the game for these seconds.";
  GuideText = GuideText@"When your connection was successful, UT will toggle itself back to fullscreen mode.";
  textArea.AddText(GuideText);
  GuideText = Chr(187)$Chr(187)$" Next is a setting to modify your in-game notifications: By disabling 'Message on channel joins/leaves', NTSC will stop from informing you on new or disconnected TS clients in your channel.";
  GuideText = GuideText@"Note that this will only stop the UT messages on the top left side of your screen; the voice notifications (e.g. 'User joined your channel') are a feature of your Teamspeak 3 Client and therefore have to be disabled in TS.";
  textArea.AddText(GuideText);
  GuideText = Chr(187)$Chr(187)$" The 'Default TS channel' setting is available if the server is configured to use multi channels. It specifies the channel you will be moved to when you join the TS server / reconnect to the gameserver.";
  GuideText = GuideText@"You can decide between the Mixed Channel, or your specific Team Channel. You can always switch the channels afterwards using the 'Switch channel' button.";
  textArea.AddText(GuideText);
  GuideText = Chr(187)$Chr(187)$" The 'Enable HUD Overlay' setting enables or disables the HUD on the left side of your screen. You can set it to be always on, only when you are connected to the Teamspeak server";
  GuideText = GuideText@"(your TS nick has to match your UT nick for that) or always off.";
  textArea.AddText(GuideText);
  textArea.AddText("");
  textArea.AddText("For your convenience, you can directly open the Teamspeak 3 Downloadpage by clicking the button on the last panel.");
  textArea.AddText("");
  GuideText = "Note that your TS nick has to match your UT nick in order for NTSC to recognize it and e.g. inform about channel joins/leaves.";
  GuideText = GuideText@"This might not work if you are using special characters in your nick. Connect via NTSC in this case, as the special characters are escaped.";
  textArea.AddText(GuideText);

  return textArea;
}

/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/

defaultproperties
{
}
