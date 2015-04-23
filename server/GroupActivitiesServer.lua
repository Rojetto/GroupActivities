class("GroupActivitiesServer")

function GroupActivitiesServer:__init()
	self.activities = {}
	self.leaderPositionTimer = Timer()
	Events:Subscribe("ClientModuleLoad", self, self.OnClientModuleLoad)
	Events:Subscribe("PlayerQuit", self, self.OnPlayerQuit)
	Events:Subscribe("PlayerEnterVehicle", self, self.OnPlayerEnterVehicle)
	Events:Subscribe("PostTick", self, self.OnTick)
	Events:Subscribe("PlayerChat", self, self.OnStaffCommand)
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

function GroupActivitiesServer:IsPlayerStaff(player)
	for _, steamIdString in pairs(GroupActivitiesConfig.Staff) do
		if tostring(player:GetSteamId()) == steamIdString then
			return true
		end
	end

	return false
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

function GroupActivitiesServer:OnStaffCommand(args)
	local arguments = {}
	for argument in args.text:gmatch("%S+") do
		table.insert(arguments, argument)
	end
	if arguments[1] == "/deleteactivity" then
		if not self:IsPlayerStaff(args.player) then
			Chat:Send(args.player, "You don't have permission to use this command", Color(255, 0, 0))
			return false
		end
		if #arguments == 2 then
			local id = tonumber(arguments[2])
			if id == nil then
				Chat:Send(args.player, "The id has to be a number", Color(255, 0, 0))
				return false
			end
			local activity = self.activities[id]
			if activity == nil then
				Chat:Send(args.player, "There is no activity with id " .. tostring(id), Color(255, 0, 0))
				return false
			end
			activity:Delete()
			Chat:Send(args.player, "The activity with id " .. tostring(id) .. " has been deleted", Color(0, 255, 0))
		else
			Chat:Send(args.player, "Format: /deleteactivity [id]", Color(255, 0, 0))
			return false
		end
		return false
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
		self:RemoveInactiveActivities()
		self:BroadcastActivities()
	end
end

function GroupActivitiesServer:OnActivityJoined(args)
	local player = Player.GetById(args.playerId)
	if self.activities[args.activityId] ~= nil then
		self.activities[args.activityId]:PlayerJoin(player)
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
	if newActivity.id == -1 then
		newActivity.id = i
		--Ugly hack to send the right messages to the leader
		local leader = Player.GetById(newActivity.leaderId)
		newActivity.leaderId = nil
		newActivity:PlayerJoin(leader)
		newActivity:PromotePlayer(leader)
	end
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
		self.activities[args.activityId]:Delete()
		self:RemoveInactiveActivities()
		self:BroadcastActivities()
	end
end

function GroupActivitiesServer:OnTeleportToLeader(playerId)
	local player = Player.GetById(playerId)
	local activity = self:GetJoinedActivity(player)

	if activity ~= nil then
		local leader = Player.GetById(activity.leaderId)
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