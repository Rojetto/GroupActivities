class("GroupActivitiesServer")

function GroupActivitiesServer:__init()
	self.activities = {}
	Events:Subscribe("ClientModuleLoad", self, self.OnClientModuleLoad)
	Events:Subscribe("PlayerQuit", self, self.OnPlayerQuit)
	Network:Subscribe("ActivityLeft", self, self.OnActivityLeft)
	Network:Subscribe("ActivityJoined", self, self.OnActivityJoined)
	Network:Subscribe("PlayerPromoted", self, self.OnPlayerPromoted)
	Network:Subscribe("ActivitySaved", self, self.OnActivitySaved)
	Network:Subscribe("ActivityDeleted", self, self.OnActivityDeleted)
end

function GroupActivitiesServer:SteamIdToPlayer(steamId)
	for player in Server:GetPlayers() do
		if steamId == player:GetSteamId() then
			return player
		end
	end
end

function GroupActivitiesServer:OnClientModuleLoad(newPlayer)
	self:BroadcastActivities()
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
	print(#activityTables)
	Network:Broadcast("ActivityList", activityTables)
end

function GroupActivitiesServer:GetJoinedActivity(player)
	for id, activity in pairs(activities) do
		if activity:IsPlayerInActivity(player) then
			return activity
		end
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
	if self.activities[args.activityId] ~= nil then
		self.activities[args.activityId]:PlayerQuit(args.player)
		self:RemoveInactiveActivities()
		self:BroadcastActivities()
	end
end

function GroupActivitiesServer:OnActivityJoined(args)
	if self.activities[args.activityId] ~= nil then
		self.activities[args.activityId]:PlayerJoin(args.player)
		self:BroadcastActivities()
	end
end

function GroupActivitiesServer:OnPlayerPromoted(args)
	if activities[args.activityId] ~= nil then
		activities[args.activityId]:PromotePlayer(args.player)
		BroadcastActivities()
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
	self:RemoveInactiveActivities()
	self:BroadcastActivities()
end

function GroupActivitiesServer:OnActivityDeleted(args)
	if self.activities[args.activityId] ~= nil then
		self.activities[args.activityId].active = false
		self:RemoveInactiveActivities()
		self:BroadcastActivities()
	end
end

GroupActivitiesServer = GroupActivitiesServer()