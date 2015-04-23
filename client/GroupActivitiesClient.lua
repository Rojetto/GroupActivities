class("GroupActivitiesClient")

function GroupActivitiesClient:__init()
	self.activities = {}
	self.browser = nil
	self.antiBoost = AntiBoost()
	self.message = ""
	self.messageTimer = Timer()
	self.leaderPositionTimer = Timer()
	self.leaderPosition = Vector3(0, 0, 0)

	Network:Subscribe("ActivityList", self, self.OnActivityListReceived)
	Network:Subscribe("Message", self, self.OnMessageReceived)
	Network:Subscribe("LeaderPosition", self, self.OnLeaderPositionReceived)
	Events:Subscribe("KeyUp", self, self.OnKey)
	Events:Subscribe("Render", self, self.RenderArrow)
	Events:Subscribe("Render", self, self.RenderMessage)
	Events:Subscribe("ModulesLoad", self, self.OnLoad)
	Events:Subscribe("ModulesLoad", self, self.AddHelp)
	Events:Subscribe("ModuleUnload", self, self.RemoveHelp)
end

function GroupActivitiesClient:AddHelp()
	Events:Fire("HelpAddItem", {name = "GroupActivities",
		text = "This script adds functionalities for organizing activities in groups.\n\n" ..
		"Open the activity browser with [" .. GroupActivitiesConfig.ActivityBrowserKeyName .. "]\n\n" ..
		[[Activities are temporary groups of people that do one specific thing together on the server.
Examples of activities include: roadtrips, airtrips, boattrips, skydives, races, airshows or just hanging out together.

Creating an activity has several advantages:  
* People that join the server can immediately see what other people are up to and join them if they like
* Activity leaders don't have to spam the chat with "roadtrip /tpm 178 peaceful"
* Activity members can always see where the leader is so that they don't get lost
* Activity members can filter the chat so that it only shows chat messages from the activity they're currently in
* If someone gets lost anyway, they can always teleport to the leader of the activity with one click

Once someone creates an activity they automatically become its leader.

Leaders have several options to customize their activity. They can
* give the activity a name and description
* make the activity public, password protected or whitelist-only
* ban disruptive players from the activity
* restrict the allowed vehicles if they want a themed trip
* block boosting in vehicles
* promote a new leader to take over the activity
* control what happens when they leave the activity.

Author: Rojetto]]
	})
end

function GroupActivitiesClient:RemoveHelp()
	Events:Fire("HelpRemoveItem", {name = "GroupActivities"})
end

function GroupActivitiesClient:OnLoad()
	if GroupActivitiesConfig.OpenOnJoin then
		self:ShowBrowser()
	end
end

function SteamIdToPlayer(steamId)
	if steamId == LocalPlayer:GetSteamId().id then return LocalPlayer end

	for player in Client:GetPlayers() do
		if steamId == player:GetSteamId().id then
			return player
		end
	end
end

function GroupActivitiesClient:OnActivityListReceived(activityList)
	self.activities = {}

	for id, activityTable in pairs(activityList) do
		self.activities[id] = Activity.FromTable(activityTable)
	end

	if self.browser ~= nil then self.browser:SetActivities(self.activities) end
end

function GroupActivitiesClient:OnMessageReceived(message)
	self.message = message
	self.messageTimer:Restart()
end

function GroupActivitiesClient:OnLeaderPositionReceived(position)
	self.leaderPositionTimer:Restart()
	self.leaderPosition = position
end

function GroupActivitiesClient:OnKey(args)
	if args.key == GroupActivitiesConfig.ActivityBrowserKey then
		self:ShowBrowser()
	end
end

function GroupActivitiesClient:GetJoinedActivity(player)
	for id, activity in pairs(self.activities) do
		if activity:IsPlayerInActivity(player) then
			return activity
		end
	end
end

function GroupActivitiesClient:ShowBrowser()
	if self.browser == nil then
		self.browser = ActivityBrowser()
		self.browser:SetActive(false)
	end
	self.browser:SetActive(not self.browser.active)
	self.browser:SetActivities(self.activities)
end

function GroupActivitiesClient:RenderArrow()
	if self.browser == nil or not self.browser:IsArrowEnabled() or self:GetJoinedActivity(LocalPlayer) == nil or self:GetJoinedActivity(LocalPlayer).leaderId == LocalPlayer:GetId() then return end
	if Game:GetState() ~= GUIState.Game then return end

	local color = GroupActivitiesConfig.LeaderColor

	local leaderPosition = Player.GetById(self:GetJoinedActivity(LocalPlayer).leaderId):GetPosition()
	if self.leaderPositionTimer:GetMilliseconds() < 1500 then
		leaderPosition = self.leaderPosition
	end
	leaderPosition = leaderPosition + Vector3(0, 2.5, 0)

	local base = Camera:GetPosition() + (Camera:GetAngle() * Vector3(0, 1.5, -7))
	local direction = (leaderPosition - base):Normalized()
	local squashedDirection = Vector3(direction.x, 0, direction.z):Normalized()
	local cross = direction:Cross(squashedDirection):Normalized()
	local vert = direction:Cross(cross):Normalized()

	local arrowShaftWidth = 0.25
	local arrowShaftLength = 0.5
	local arrowHeadWidth = 0.5
	local arrowHeadLength = 0.25

	local a = cross * (arrowShaftWidth / 2)
	local b = direction * arrowShaftLength
	local c = cross * (arrowHeadWidth / 2) - a
	local d = direction * arrowHeadLength

	Render:FillTriangle(base + a, base + a + b, base - a, color)
	Render:FillTriangle(base + a + b, base - a + b, base - a, color)
	Render:FillTriangle(base + a + b + c, base + b + d, base - a + b - c, color)

	a = vert * (arrowShaftWidth / 2)
	c = vert * (arrowHeadWidth / 2) - a

	Render:FillTriangle(base + a, base + a + b, base - a, color)
	Render:FillTriangle(base + a + b, base - a + b, base - a, color)
	Render:FillTriangle(base + a + b + c, base + b + d, base - a + b - c, color)

	local distance = (leaderPosition - LocalPlayer:GetPosition()):Length()
	local distanceText = math.floor(distance).." m"
	if distance > 1000 then
		distanceText = (math.floor(distance / 10) / 100).." km"
	end
	local boxWidth = Render:GetTextWidth(distanceText, 20) + 10
	local boxHeight = Render:GetTextHeight(distanceText, 20) + 10

	local screenPos, onScreen = Render:WorldToScreen(leaderPosition)
	if onScreen then
		Render:FillCircle(screenPos, 10, color)
		Render:FillArea(screenPos + Vector2(20, (-1) * boxHeight / 2), Vector2(boxWidth, boxHeight), Color(0, 0, 0, 150))
		Render:DrawText(screenPos + Vector2(25, -7), distanceText, Color(255, 255, 255), 20)
	end
end

function GroupActivitiesClient:RenderMessage()
	if self.messageTimer:GetSeconds() < 5 then
		local textSize = Render:GetTextSize(self.message, 40)

		Render:DrawText((Render.Size / 2) - (textSize / 2) - Vector2(0, Render.Height / 3), self.message, Color(255, 0, 0), 40)
	end
end

function GroupActivitiesClient:JoinActivity(activity)
	Network:Send("ActivityJoined", {activityId = activity.id, playerId = LocalPlayer:GetId()})
end

function GroupActivitiesClient:LeaveActivity(activity)
	Network:Send("ActivityLeft", {activityId = activity.id, playerId = LocalPlayer:GetId()})
end

function GroupActivitiesClient:PromotePlayer(activity, player)
	Network:Send("PlayerPromoted", {activityId = activity.id, playerId = player:GetId()})
end

function GroupActivitiesClient:SaveActivity(activity)
	Network:Send("ActivitySaved", activity:ToTable())
end

function GroupActivitiesClient:DeleteActivity(activity)
	Network:Send("ActivityDeleted", {activityId = activity.id})
end

function GroupActivitiesClient:TeleportToLeader()
	Network:Send("TeleportToLeader", LocalPlayer:GetId())
end

function GroupActivitiesClient:SetVehicleVelocity(velocity)
	Network:Send("VehicleVelocity", {playerId = LocalPlayer:GetId(), velocity = velocity})
end

GroupActivitiesClient = GroupActivitiesClient()