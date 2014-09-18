class("GroupActivitiesServer")

function GroupActivitiesServer:__init()
	self.activities = {}
	self.leaderPositionTimer = Timer()
	Events:Subscribe("ClientModuleLoad", self, self.OnClientModuleLoad)
	Events:Subscribe("PlayerQuit", self, self.OnPlayerQuit)
	Events:Subscribe("PlayerEnterVehicle", self, self.OnPlayerEnterVehicle)
	Events:Subscribe("PostTick", self, self.OnTick)
	Network:Subscribe("ActivityLeft", self, self.OnActivityLeft)
	Network:Subscribe("ActivityJoined", self, self.OnActivityJoined)
	Network:Subscribe("PlayerPromoted", self, self.OnPlayerPromoted)
	Network:Subscribe("ActivitySaved", self, self.OnActivitySaved)
	Network:Subscribe("ActivityDeleted", self, self.OnActivityDeleted)
	Network:Subscribe("TeleportToLeader", self, self.OnTeleportToLeader)
	Network:Subscribe("VehicleVelocity", self, self.OnVehicleVelocity)
end

function SteamIdToPlayer(steamId)
	for player in Server:GetPlayers() do
		if steamId == player:GetSteamId().id then
			return player
		end
	end
end

function GroupActivitiesServer:OnClientModuleLoad(newPlayer)
	self:BroadcastActivities()
end

function GroupActivitiesServer:OnTick()
	if self.leaderPositionTimer:GetMilliseconds() > 1000 then
		for player in Server:GetPlayers() do
			if self:GetJoinedActivity(player) ~= nil then
				local leader = Player.GetById(self:GetJoinedActivity(player).leaderId)
				local leaderPosition = leader:GetPosition()

				if (leaderPosition - player:GetPosition()):Length() > Config:GetValue("Streamer", "StreamDistance") then
					Network:Send(player, "LeaderPosition", leaderPosition)
				end
			end
		end

		self.leaderPositionTimer:Restart()
	end
end

function GroupActivitiesServer:RemoveInactiveActivities()
	for _, activity in pairs(self.activities) do
		if not activity.active then
			self.activities[activity.id] = nil
		end
	end
end

function GroupActivitiesServer:BroadcastActivities()
	local activityTables = {}
	for id, activity in pairs(self.activities) do
		activityTables[id] = activity:ToTable()
	end
	Network:Broadcast("ActivityList", activityTables)
end

function GroupActivitiesServer:GetJoinedActivity(player)
	for id, activity in pairs(self.activities) do
		if activity:IsPlayerInActivity(player) then
			return activity
		end
	end
end

function GroupActivitiesServer:OnPlayerEnterVehicle(args)
	if self:GetJoinedActivity(args.player) ~= nil and not self:GetJoinedActivity(args.player).allowedVehicles[args.vehicle:GetModelId()] then
		args.player:SetPosition(args.player:GetPosition())
		Network:Send(args.player, "Message", "This vehicle is not allowed in this activity")
	end
end

function GroupActivitiesServer:OnPlayerQuit(args)
	for _, activity in pairs(self.activities) do
		if activity:IsPlayerInActivity(args.player) then
			activity:PlayerQuit(args.player)
		end
	end

	self:RemoveInactiveActivities()
	self:BroadcastActivities()
end

function GroupActivitiesServer:OnActivityLeft(args)
	local player = Player.GetById(args.playerId)
	if self.activities[args.activityId] ~= nil then
		self.activities[args.activityId]:PlayerQuit(player)
		Chat:Send(player, 'You have left "' .. self.activities[args.activityId].name .. '"', Color(0, 255, 0))
		self:RemoveInactiveActivities()
		self:BroadcastActivities()
	end
end

function GroupActivitiesServer:OnActivityJoined(args)
	local player = Player.GetById(args.playerId)
	if self.activities[args.activityId] ~= nil then
		self.activities[args.activityId]:PlayerJoin(player)
		Chat:Send(player, 'You have joined "' .. self.activities[args.activityId].name .. '"', Color(0, 255, 0))
		self:BroadcastActivities()
		self:OnTeleportToLeader(args.playerId)
		if player:InVehicle() and not self.activities[args.activityId].allowedVehicles[player:GetVehicle():GetId()] then
			player:SetPosition(player:GetPosition())
			Network:Send(player, "Message", "This vehicle is not allowed in this activity")
		end
	end
end

function GroupActivitiesServer:OnPlayerPromoted(args)
	local player = Player.GetById(args.playerId)
	if self.activities[args.activityId] ~= nil then
		self.activities[args.activityId]:PromotePlayer(player)
		Chat:Send(player, 'You were promoted to the leader of "' .. self.activities[args.activityId].name .. '"', Color(0, 255, 0))
		self:BroadcastActivities()
	end
end

function GroupActivitiesServer:OnActivitySaved(table)
	--we find the next free activityId
	local newActivity = Activity.FromTable(table)
	local i = 1
	while self.activities[i] ~= nil do
		i = i + 1
	end
	if newActivity.id == -1 then newActivity.id = i end
	self.activities[newActivity.id] = newActivity
	Chat:Send(Player.GetById(self.activities[newActivity.id].leaderId), "The activity has been saved", Color(0, 255, 0))
	for player, _ in pairs(self.activities[newActivity.id]:GetBannedPlayers()) do
		self.activities[newActivity.id]:PlayerQuit(player)
		Chat:Send(player, 'You\'ve been banned from "' .. self.activities[newActivity.id].name .. '"', Color(255, 0, 0))
	end
	self:RemoveInactiveActivities()
	self:BroadcastActivities()
end

function GroupActivitiesServer:OnActivityDeleted(args)
	if self.activities[args.activityId] ~= nil then
		self.activities[args.activityId].active = false
		Chat:Send(Player.GetById(self.activities[args.activityId].leaderId), "The activity has been deleted", Color(0, 255, 0))
		self:RemoveInactiveActivities()
		self:BroadcastActivities()
	end
end

function GroupActivitiesServer:OnTeleportToLeader(playerId)
	local player = Player.GetById(playerId)
	local activity = self:GetJoinedActivity(player)

	if activity ~= nil then
		local leader = Player.GetById(activity.leaderId)
		player:SetWorld(leader:GetWorld())
		player:SetPosition(leader:GetPosition())
	end
end

function GroupActivitiesServer:OnVehicleVelocity(args)
	local player = Player.GetById(args.playerId)
	if not player:InVehicle() then return end
	if not player:GetState() == PlayerState.InVehicle then return end

	player:GetVehicle():SetLinearVelocity(args.velocity)
	Network:Send(player, "Message", "Boosting is not allowed in this activity")
end

GroupActivitiesServer = GroupActivitiesServer()