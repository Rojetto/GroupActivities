## Overview ##
GroupActivities is a script for Just Cause 2 Multiplayer servers that adds group functionalities.  
The difference to existing plugins is the nature of groups. They are not permanent like factions, but temporary, easy to create and delete for everyone. That's why they're often only called "Activities" in the script.  
GroupActivities is completely GUI-controlled. Everything starts with opening the activity browser (standard: F7). From there, everyone can create their own activity or join an existing one.

## Activities ##
Activities are temporary groups of people that do one specific thing together on the server.
Examples of activities include: roadtrips, airtrips, boattrips, skydives, races, airshows or just hanging out together.

Creating an activity has several advantages:  
* People that join the server can immediately see what other people are up to and join them if they like
* Activity leaders don't have to spam the chat with "roadtrip /tpm 178 peaceful"
* Activity members can always see where the leader is so that they don't get lost
* Activity members can filter the chat so that it only shows chat messages from the activity they're currently in
* If someone gets lost anyway, they can always teleport to the leader of the activity with one click

## Activity leaders ##
Once someone creates an activity they automatically become its leader.

Leaders have several options to customize their activity. They can
* give the activity a name and description
* make the activity public, password protected or whitelist-only
* ban disruptive players from the activity
* restrict the allowed vehicles if they want a themed trip
* block boosting in vehicles
* promote a new leader to take over the activity
* control what happens when they leave the activity.

## Configuration ##
Open "GroupActivities\shared\Config.lua" to configure the following options:
* "ActivityBrowserKey" is the hotkey that opens the activity browser
* "ActivityBrowserKeyName" is the name of the activity browser hotkey that gets displayed in the help menu
* "OpenOnJoin" controls, whether the activity browser should automatically open when a player joins the server
* "LeaderColor" changes the color that the arrow that shows to the leader and their chat messages in the activity chat have
* "StaffActivityChatFix" needs to be activated when you have scripts, that change chat messages by staff members by changing their color or adding a prefix, to prevent staff messages from being sent twice in the activity chat
* "Staff" is a list of SteamIds of players, that have permission to use the /deleteactivity command

Author: Rojetto