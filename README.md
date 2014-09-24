## Overview ##
GroupActivities is a script for Just Cause 2 Multiplayer servers that add group functionalities.  
The difference to existing plugins is the nature of groups. They are not permanent like factions, but temporary, easy to create and delete for everyone. That's why they're often only called "Activities" in the script.  
GroupActivities is completely GUI-controlled. Everything starts with opening the activity browser (standard: F7). From there, everyone can create his own activity or join an existing one.

## Activities ##
Activities are temporary groups of people that do one specific thing together on the server. Creating an activity has several advantages:  
* People that join the server can immediately see what other people are up to and join them if they like
* Activity leaders don't have to spam the chat with "roadtrip /tpm 178 peaceful"
* Activity members can always get displayed where the leader is so that they don't get lost
* Activity members can filter the chat so that it only shows chat messages from the activity they're currently in
* If someone gets lost anyway, they can always teleport to the leader of the activity with one click

Examples of activities include: roadtrips, airtrips, boattrips, skydives, races, airshows or just hanging out together.

## Activity leaders ##
Once someone creates an activity they automatically become its leader. Leaders have several options to customize their activity. They can
* give the activity a name and description
* make the activity public, password protected or whitelist-only
* ban disruptive players from the activity
* restrict the allowed vehicles if they want a themed trip
* block boosting in vehicles
* promote a new leader to take over the activity
* control what happens when they leave the server. Should the activity be automatically deleted or should a random member be promoted to leader?

## Configuration ##
Open "GroupActivities/client/Config.lua" to configure the following options:
* "ActivityBrowserKey" is the hotkey that opens the activity browser
* "ActivityBrowserKeyName" is the name of the activity browser hotkey that gets displayed in the help menu
* "OpenOnJoin" controls, whether the activity browser should automatically open when a player joins the server

If you want to use /deleteactivity to delete activities that break the rules, you have to add staff members to "GroupActivities/server/Staff.lua".