class("GroupActivitiesClient")

function GroupActivitiesClient:__init()
	self.activities = {}
	self.browser = nil

	Network:Subscribe("ActivityList", self, self.OnActivityListReceived)
	Events:Subscribe("KeyUp", self, self.OnKey)
	Events:Subscribe("Render", self, self.RenderArrow)
end

function GroupActivitiesClient:SteamIdToPlayer(steamId)
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

function GroupActivitiesClient:OnKey(args)
	if args.key == Config.ActivityBrowserKey then
		self:ShowBrowser()
	end
end

function GroupActivitiesClient:GetJoinedActivity()
	for id, activity in pairs(self.activities) do
		if activity:IsPlayerInActivity(LocalPlayer) then
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
	--if self.browser == nil or not self.browser:IsArrowEnabled() or self:GetJoinedActivity() == nil or self:GetJoinedActivity().leader == LocalPlayer then return end

	local color = Color(0, 255, 0)

	--local leaderPosition = self:GetJoinedActivity().leader:GetPosition()
	local leaderPosition = Vector3(-9832, 267, -2867)
	--local base = LocalPlayer:GetPosition() + (LocalPlayer:GetAngle() * Vector3(0, 2, 0))
	local base = Camera:GetPosition() + (Camera:GetAngle() * Vector3(0, 1.5, -7))
	local direction = (leaderPosition - base):Normalized()
	local squashedDirection = Vector3(direction.x, 0, direction.z):Normalized()
	local cross = direction:Cross(squashedDirection):Normalized()

	local arrowShaftWidth = 0.25
	local arrowShaftLength = 1
	local arrowHeadWidth = 0.5
	local arrowHeadLength = 0.25

	local halfShaftBase = cross * (arrowShaftWidth / 2)
	local shaftLength = direction * arrowShaftLength
	local headBase = cross * (arrowHeadWidth / 2) - halfShaftBase
	local headDiagonal = cross * (arrowHeadWidth / 2) * (-1) + (direction * arrowHeadLength)
	local flippedHeadDiagonal = cross * (arrowHeadWidth / 2) + (direction * arrowHeadLength)

	Render:DrawLine(base, base + halfShaftBase, color)
	Render:DrawLine(base + halfShaftBase, base + halfShaftBase + shaftLength, color)
	Render:DrawLine(base + halfShaftBase + shaftLength, base + halfShaftBase + shaftLength + headBase, color)
	Render:DrawLine(base + halfShaftBase + shaftLength + headBase, base + halfShaftBase + shaftLength + headBase + headDiagonal, color)

	Render:DrawLine(base, base - halfShaftBase, color)
	Render:DrawLine(base - halfShaftBase, base - halfShaftBase + shaftLength, color)
	Render:DrawLine(base - halfShaftBase + shaftLength, base - halfShaftBase + shaftLength - headBase, color)
	Render:DrawLine(base - halfShaftBase + shaftLength - headBase, base - halfShaftBase + shaftLength - headBase + flippedHeadDiagonal, color)

	Render:DrawText(Vector2(100, 300), math.floor(base.x).." "..math.floor(base.y).." "..math.floor(base.z), Color(255, 255, 255))
end

function GroupActivitiesClient:JoinActivity(activity)
	Network:Send("ActivityJoined", {activityId = activity.id, player = LocalPlayer})
end

function GroupActivitiesClient:LeaveActivity(activity)
	Network:Send("ActivityLeft", {activityId = activity.id, player = LocalPlayer})
end

function GroupActivitiesClient:PromotePlayer(activity, player)
	Network:Send("PlayerPromoted", {activityId = activity.id, player = player})
end

function GroupActivitiesClient:SaveActivity(activity)
	Network:Send("ActivitySaved", activity:ToTable())
end

function GroupActivitiesClient:DeleteActivity(activity)
	Network:Send("ActivityDeleted", {activityId = activity.id})
end

function GroupActivitiesClient:TeleportToLeader()
	Network:Send("TeleportToLeader", LocalPlayer)
end

GroupActivitiesClient = GroupActivitiesClient()