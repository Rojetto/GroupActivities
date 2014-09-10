## Overview ##
GroupActivities is a script for Just Cause 2 Multiplayer servers that add group functionalities.  
The difference to existing plugins is the nature of groups. They are not permanent like factions, but temporary, easy to create and delete for everyone. That's why they're often only called "Activities" in the script.  
GroupActivities is completely GUI-controlled. Everything starts with opening the activity browser (standard: F7). From there, everyone can create his own activity or join an existing one.

## Activities ##
Activities are temporary groups of people that do one specific thing together on the server. Creating an activity has several advantages:  
* People that join the server can immediately see what other people are up to and join them if they like
* Activity leaders don't have to spam the chat with "roadtrip /tpm 178 peaceful"
* Activity members can always get displayed where the leader is so that they don't get lost
* If someone gets lost anyway, they can always teleport to the leader of the activity with one click

Examples of activities include: roadtrips, airtrips, boattrips, skyjumps, races, airshows or just hanging out together.

## Activity leaders ##
Once someone creates an activity they automatically become its leader. Leaders have several options to customize their activity:
* They can give the activity a name and description
* They can make an activity public, password protected or whitelist-only
* They can ban disruptive players from the activity
* They can restrict the allowed vehicles if they want a themed trip
* They can promote a new leader to take over the activity
* They can control what happens when they leave the server. Should the activity be automatically deleted or should a random member be promoted to leader?

## Configuration ##
To configure this script, open "GroupActivites" in your server's script folder and go to "client". In "Config.lua" you can configure the following options:
* Config.ActivityBrowserKey is the hotkey that opens the activity browser
* Config.OpenOnJoin controls, whether the activity browser should automatically open when a player joins the server