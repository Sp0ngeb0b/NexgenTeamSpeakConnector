**Preview:**

![preview](https://user-images.githubusercontent.com/12958319/77364249-71136b80-6d54-11ea-85ce-d922eb4117f1.jpg)
![previewMulti](https://user-images.githubusercontent.com/12958319/77364286-7c669700-6d54-11ea-8d0f-e9c6ae566135.jpg)
![previewHUD](https://user-images.githubusercontent.com/12958319/77364294-7e305a80-6d54-11ea-8a7d-802a45f5be9e.jpg)

```
####################################################################################################
##
##  Nexgen Teamspeak 3 Connector - NTSC
##  [NexgenTeamSpeakConnector201 - For Nexgen 112]
##
##  Version: 2.01
##  Release Date: September 2020
##  Author: Patrick "Sp0ngeb0b" Peltzer
##  Contact: spongebobut@yahoo.com  -  www.unrealriders.eu
##
####################################################################################################
##   Table of Content
##
##   1. Introduction
##   2. Features
##   3. Client manual
##   4. Server requirements
##   5. Teamspeak Setup
##   6. Gameserver Setup
##   7. Gameserver configuration
##   8. Credits and thanks
##   9. Info for programmers
##  10. Changelog
##
####################################################################################################

####################################################################################################
##
##  1. Introduction
##
####################################################################################################
After more than 5 years and a break from UT, the Nexgen TeamSpeak 3 Connector (NTSC) got a complete 
overhault - presenting version 2!

NTSC introduces a proper voice communication integration to UT99, using the 3rd party software
Teamspeak 3. A serveradmin can use this plugin to connect his gameserver to a Teamspeak 3 server -
players will be able to conveniently connect to predefined channel(s), receive live data from the
teamspeak server ingame and more.

####################################################################################################
##
##  2. Features
##
####################################################################################################
- Connect to the gameserver's Teamspeak 3 server conveniently
- Get live data from the Teamspeak server. This includes:
  - Other clients in the channel(s)
  - See whether a client is talking, silent or muted
  - Get informed about new clients or left client in your channel 
- The data is displayed in Nexgen or via a HUD overlay directly on your screen
- 2 modes for serveradmins:
  - Single channel mode: All players are in a single Teamspeak channel.
  - Multi channel mode: Players are automatically sorted in their respective team channel, or in a
    mixed channel for all players. This mode can be used to make exclusive gameserver channels!


####################################################################################################
##
##  3. Client manual
##
####################################################################################################
To use this mod, the Teamspeak 3 Client needs to be installed on your computer. You can download it 
for a selection of operating system for FREE from their official site:

http://www.teamspeak.com/?page=downloads

Follow the install instructions to set it up correctly. No further information or support is provided 
on this matter,as it is not related to this plugin. If you need help, look on their homepage or post 
in the TS forum.

The following manual assumes that you have installed and configured Teamspeak 3 correctly.

As soon as you are connected to a UT99 gameserver running this plugin, you will find the NTSC in-game 
tab in Nexgen. Say '!open' to bring up the Nexgen window and click on the tab 'Teamspeak' on the upper
end of the window. 
Alternatively, you can directly bring up the tab by saying '!ts'.

Depending on the gameserver's configuration, you'll either see a single list or 4 lists on the left 
half of the tab, and 3 panels on the right half. The former are the live channel query lists and 
display the current players connected to the TS server in their respective channel. Additional 
teamspeak flags are displayed as an icon to indicate standby, speaking, muted microphone or no 
microphone.

The first panel on the right allows you to control your connection to the TS server. By clicking the 
button 'Connect', it will start up your Teamspeak 3 Client and lets it connect to the gameserver's 
specific Teamspeak server. NOTE: UT may minimize during this process. You can either switch back to 
UT manually, or use the setting 'Connect in windowed Mode' (see further below for more info). Your OS 
may open up a window asking which program to use. If so, continue by selecting the Teamspeak 3 Client 
in the pop up window and click OK. If setup right, your Teamspeak 3 Client will start up now and 
automatically connect to the Teamspeak server. If the server is configured to use a single channel, 
you automatically enter it on join. Otherwise, NTSC will move you to your desired channel according to 
your 'Default TS Channel' setting.
Hint: You can perform this action quickly by saying '!tsjoin'.

Clicking the 'Disconnect' button will close your connection to the TS server. Teamspeak will tell you 
that you have been kicked from the server - don't worry, that's how it's supposed to be and you are 
neither kicked or banned for good.
Hint: You can perform this action quickly by saying '!tsleave'.

'Change Channel' - as the name suggests, this button allows you to switch between the Mixed Channel 
and your specifc Team Channel if the server is configured to use multi channels.
Hint: You can perform this action quickly by saying '!tsswitch'.

Underneath the Control panel you'll find 5 personal client-settings to optimize your Teamspeak 
experience:

- The first setting, called 'Auto connect to TS on join', will automatically run the 'Connect' action 
  after joined the gameserver if you are not connected to TS yet.

- 'Connect in windowed mode' is relevant when your client initially connects to the TS server. UT will 
  minimize during this process. However, you can minimize the impact on your gameplay by enabling this 
  option: As soon as you press the 'Connect' button, UT will switch to windowed mode, preventing the 
  game from minimizing completely and allows you to still take part in the game for these seconds. 
  When your connection was successful, UT will toggle itself back to fullscreen mode.

- Next is a setting to modify your in-game notifications: By disabling 'Message on channel joins/
  leaves', NTSC will stop from informing you on new or disconnected TS clients in your channel.
  Note that this will only stop the UT messages on the top left side of your screen; the voice 
  notifications (e.g. 'User joined your channel') are a feature of your Teamspeak 3 Client and 
  therefore have to be disabled in TS.

- The 'Default TS channel' setting is available if the server is configured to use multi channels. It 
  specifies the channel you will be moved to when you join the TS server / reconnect to the gameserver. 
  You can decide between the Mixed Channel, or your specific Team Channel. You can always switch the 
  channels afterwards using the 'Switch channel' button.

- The 'Enable HUD Overlay' setting enables or disables the HUD on the left side of your screen. You can
  set it to be always on, only when you are connected to the Teamspeak server (your TS nick has to match 
  your UT nick for that) or always off.

For your convenience, you can directly open the Teamspeak 3 Downloadpage by clicking the button on the last panel.

Note that your TS nick has to match your UT nick in order for NTSC to recognize it and e.g. inform about channel joins/leaves.
This might not work if you are using special characters in your nick. Connect via NTSC in this case, as the special characters are escaped.

####################################################################################################
##
##  4. Server requirements
##
####################################################################################################
Teamspeak:
  - A functional Teamspeak 3 server with a static IP and/or a DNS adress
  - ServerQuery Login credentials
  - Access to the white_list.txt (in case of issues)
  
UnrealTournament:
  - Nexgen 112

####################################################################################################
##
##  5. Teamspeak Setup
##
####################################################################################################
Pre-Setup:
==========
NTSC uses Teamspeak's ServerQuery feature to communicate with the Teamspeak server. The ServerQuery
account needs to have the following permissions in order for NTSC to operate properly:

- Retrieve the channel- and client data
- Kick clients
- Move clients to other channels

There are two options to retrieve the ServerQuery credentials:
- Connect with your Teamspeak client to the Teamspeak 3 server. Go to Tools -> ServerQuery Login,
  enter a name and a password and use them in NTSC. Note that your Teamspeak client needs to have
  appropriate permissions on the server to create login credentials. 
- Look up your TeamSpeak3 serveradmin password. If you are running your own dedicated TS3 server, you
  specify the password with the parameter "serveradmin_password=" while using the server start script.
  If you are running a hosted server, look out for the keyword "adminpassword"/"query password".
  
Also make sure you add your gameserver's IP adress to the Teamspeak white list. Failing to do so
can result in your Teamspeak server from blocking the connection and NTSC not working. You can find 
the list in the file "white_list.txt" in the Teamspeak server root folder, or use your specific hoster
panel/support to whitelist the IP.

Channel Setup:
==============
NTSC has 2 operating modes: 
- Single channel mode will only use a single channel for all players
- Multi channel mode supports up to 6 channels

The channel names can be be specified in the NTSC ingame settings tab in Nexgen, or directly via the
NexgenTeamspeakConnector.ini file. Make sure the names exactly match the ones in the Teamspeak
server!

Single channel mode:
- Default Channel: This is the channel the player initially joins after connecting to the Teamspeak
                   server and the channel used when in single channel mode. A good name could be your
                   gameserver's name.
                   
Multi channel mode:                                     
- Default Channel: In multi channel mode, the client will automatically be moved to the other channels 
                   after connecting. Therefore, the Default Channel isn't required and can be left 
                   blank. Note that if you dont specify a Default Channel, NTSC will move the player 
                   from ANY channel of the Teamspeak server to the other channels. If you don't want 
                   this behaviour, you should specify a Default Channel. Note that if you do set a 
                   Default Channel, NTSC preferes the other NTSC channels to be Subchannels of the 
                   Default Channel - this allows multiple gameservers to use the same Teamspeak server.

- Mixed Channel, Red Team, Blue Team, Spectators: 
                   These determine the names of the teamchannels and the channel for all players.
                   Note that if you are running non-teamgames, the Red Channel will be used for all 
                   players. Renaming to just "Players" might be desired then.

- Disconnected Players: 
                   This Channel is for players who left your server either because of a disconenct or 
                   during mapchanges. I recommend to set up an idle kick on your Teamspeak server for 
                   this channel, in order to remove the players from the Teamspeak server after some 
                   time. To do so, enable the right "i_client_max_idletime" for the Disconnected
                   Players channel in Teamspeak's Permission Panel, where the "value" means the max 
                   idle time in seconds. Specifiying this channel guarantees that only current players
                   are in the other channels.

I recommend to password protect all your channels in multi channel mode in order to ensure your gaming 
channels will stay exclusive to the gamers and channels can't be changed manually. Make sure you use a 
different password for your default Channel than for the other channels, since this one will be 
replicated to the clientside and can possibly be read by each client connecting.

Examples:


Single channel mode:
- Channel X
- Channel Y
- Gameserver Channel (default channel, all players share this channel) 
- Channel Z

Multi channel mode, 1 gameserver, no default channel:
- Entry hall (players will be moved)
- Gameserver
  ° Mixed Channel
  ° Red Team
  ° Blue Team
  ° Spectators
  ° Disconnected Player
- Other Channel (players will be moved)
- Another Channel (players will be moved)

Multi channel mode, 1 gameserver, with default channel:
- Entry Hall (players will NOT be moved)
- Gameserver (default connection channel, players will be moved)
  ° Mixed Channel
  ° Red Team
  ° Blue Team
  ° Spectators
  ° Disconnected Player
- Other Channel (players will NOT be moved)
- Another Channel (players will NOT be moved)

Multi channel mode, multiple gameserver, default channels are required:
- Entry Hall
- Gameserver 1 (default connection channel for this gameserver)
  ° Mixed Channel
  ° Red Team
  ° Blue Team
  ° Spectators
  ° Disconnected Player
- Other Channel
- Gameserver 2 (default connection channel for this gameserver)
  ° Mixed Channel
  ° Red Team
  ° Blue Team
  ° Spectators
  ° Disconnected Player

####################################################################################################
##
##  6. Gameserver Setup
##
####################################################################################################
New install:
 1. Make sure your server has been shut down.

 2. Copy NexgenTeamSpeakConnector201.u to the system folder of your UT server.

 3. If your server is using redirect upload the NexgenTeamSpeakConnector201.u.uz file
    to the redirect server.

 4. Open your servers configuration file and add the following server package:

      ServerPackages=NexgenTeamSpeakConnector201

    Also add the following server actors in the exact order:

      ServerActors=NexgenTeamSpeakConnector201.NexgenTeamSpeakConnector
      
    Note that the actors should be added AFTER the Nexgen controller server actor
    (ServerActors=Nexgen112.NexgenActor).

 5. Restart your server. If the installation was succesfull, you can now modify the NTSC settings
    directly in your server. Therefore, connect to your gameserver, open Nexgen by saying '!open'
    and navigate to the "Server -> Settings -> Plugins" tab, and look out for the Nexgen TeamSpeak
    Connector settings. Modify the settings based on the explanations below. Reload/change the
    current map and if your settings are valid, the 'Teamspeak' tab should now be available in
    Nexgen. If it's not, open your server's log file and look out for any error message prefixed by
    [NexgenTeamSpeakTCP]. If you need further details, enable the Internal Debug option.
    
Updating from a previous version:
 1. Make sure your server has been shut down.

 2. Delete NexgenTeamSpeakConnectorXXX.u from your servers system folder and upload 
    NexgenTeamSpeakConnector201.u to the same folder.

 3. If your server is using redirect you may wish to delete NexgenTeamSpeakConnectorXXX.u.uz if 
    it is no longer used by other servers. Also upload NexgenTeamSpeakConnector201.u.uz to the 
    redirect server.

 4. Open NexgenTeamSpeakConnector.ini.

 5. Do a search and replace "NexgenTeamSpeakConnectorXXX." with "NexgenTeamSpeakConnector201." 
    (without the quotes).

 6. Save the changes and close the file.

 7. Goto the [Engine.GameEngine] section and edit the server package and
    server actor lines for Nexgen. They should look like this:

      ServerActors=NexgenTeamSpeakConnector201.NexgenTeamSpeakConnector

      ServerPackages=NexgenTeamSpeakConnector201

 8. Save changes to the servers configuration file and close it.

 9. Restart your server.
    
####################################################################################################
##
##  7. Gameserver configuration
##
####################################################################################################
The following is an explanation for each setting available in the ingame config tab:

"Enable Teamspeak Connector": Check this box if you want the Teamspeak Connector to start.

"Write internal debug log":   Enabling this option will print out further debugging log into your
                              server's log file.
                              
"Query timer period":         Determines the period until another query request is sent to the 
                              Teamspeak server. Only change in case of issues (e.g. spam
                              protection).
                              
"Mode":                       Specify whether to use single channel mode (0) or multi channel 
                              mode (1).                              
                            
"Teamspeak adress":           The IP/DNS adress for your Teamspeak server.

"Teamspeak join port":        The incoming UDP port of the Teamspeak server to accept connections.
                              Default: 9987
                       
"Teamspeak query port":       The incoming TCP port of the Teamspeak server to accept query 
                              connections.
                              Default: 10011
                        
"Teamspeak password":         The global server password for your Teamspeak server (if set).
                              Note that this might be read by every client connecting to your Server.

"Teamspeak username":         The username to perform querying actions. Default is "serveradmin" and 
                              usually doesn't need to be changed.
                      
"Teamspeak userpassword":     The password belonging to the username. Further explained in 5).

"Default Channel password":   The password for the default connection Channel (if set).
                              Note that this might be read by every client connecting to your Server.
                                                  
"Mixed Channel":              The name of your TeamSpeak Channel for all clients. Default is 
                              "Mixed Channel" and usually doesn't need to be changed.

"Red Team Channel":           The name of your TeamSpeak Channel for the Red Team, or if a 
                              non-teamgame, for all players. Default is "Red Team" and might be 
                              changed to "Players" in non-teamgames.
                    
"Blue Team Channel":          The name of your TeamSpeak Channel for the Blue Team. Default is 
                              "Blue Team" and might be left blank for non-teamgames.
                                          
"Spectator Channel":          The name of your TeamSpeak Channel for the Spectators.
                              Default is "Spectators" and usually doesn't need to be changed.
                     
"Disconnected Player          The name of your TeamSpeak Channel for all disconnected Players.
            Channel":         Default is "Disconnected Players" and usually doesn't need to be changed.
    
####################################################################################################
##
##  8. Credits and thanks
##
####################################################################################################
- Defrost for developing Nexgen and his work on the TCP implementation in Nexgen 1.12. 
 (http://www.unrealadmin.org/forums/showthread.php?t=26835)

- To my admin team and players from the 'ComboGib >GRAPPLE< Server <//UrS//>', for their testing,
  bug-finding and feedback.

####################################################################################################
##
##  9. Info for programmers
##
####################################################################################################
This mod is open source. You can view/and or use the source code of it partially or entirely without
my permission. You are also more then welcome to recompile this mod for another Nexgen version.
Nonetheless I would like you to follow these limitations:

- If you use parts of this code for your own projects, please give credits to me in your readme.
  (Patrick 'Sp0ngeb0b' Peltzer)

- If you recompile or edit this plugin, please leave the credits part of the readme intact.
  Also note that you have to pay attention to the naming of your version to avoid missmatches.
  All official updates will be made ONLY by me and therefore counting up version numbers are
  forbidden (e.g. NexgenTeamSpeakConnector201). Instead, add an unique suffix
  (e.g. NexgenTeamSpeakConnector200_bla).

While working with Nexgen's 1.12 TCP functions, I encountered a far-reaching bug in Nexgen's core
file which will prevent empty strings in an array to be transfered correctly. A detailed explanation
and solution can be found here: http://www.unrealadmin.org/forums/showthread.php?t=31280


####################################################################################################
##
##  10. Changelog
##
####################################################################################################
- Version 2.01:
  [Added]     - Teaspeak (teaspeak.de) server support
  [Fixed]     - Possible channel detection fail

- Version 2.00:
  [Changed]   - Teamspeak query is now periodic instead of event driven
  [Added]     - Non-UT TS clients are now also displayed and considered for joins/leaves messages
              - Additional TS flags are displayed (country, talking, muted, microphone available)
              - Single channel mode
              - HUD overlay
              - Tab caption displays connected client amount
  [Fixed]     - Going into windowed mode when client was already in it caused going fullscreen
  [Removed]   - Check connection button as it is no longer used

- Version 1.00:
  [Misc]: - First public release.



Bug reports / feedback / questions / debugging requests can be send directly to me.



Sp0ngeb0b, September 2020

admin@unrealriders.eu / spongebobut@yahoo.com
www.unrealriders.eu
```



