Access = {}
Access.Public = "Public"
Access.Password = "Password"
Access.Whitelist = "Whitelist"

OnLeaveAction = {}
OnLeaveAction.Delete = "Delete activity"
OnLeaveAction.Promote = "Promote a random player"

class("Activity")

function Activity:__init(activityId, name, leader)
	self.active = true
	self.id = activityId
	self.name = name
	self.description = ""
	self.access = Access.Public
	self.password = ""
	self.leader = leader
	self.onLeaveAction = OnLeaveAction.Promote
	self.members = {}
	self.bannedSteamIds = {}
	self.whitelistedSteamIds = {}
	self.allowedVehicles = {}
	self.boost = true
end

function Activity:PlayerJoin(player)
	self.members[player] = true
end

function Activity:PlayerQuit(player)
	self.members[player] = nil
	if self.leader == player then
		if self.onLeaveAction == OnLeaveAction.Delete then
			self.active = false
		elseif self.onLeaveAction == OnLeaveAction.Promote then
			if #self.members == 0 then
				self.active = false
			else
				local key, value = next(self.members)
				self.leader = key
				self.members[key] = nil
			end
		end
	end
end

function Activity:PromotePlayer(player)
	if self.members[player] == true then
		self.members[self.leader] = true
		self.members[player] = nil
		self.leader = player
	end
end

function Activity:IsVehicleAllowed(vehicleId)
	return self.allowedVehicles[vehicleId] == true
end

function Activity:IsPlayerInActivity(player)
	return self.members[player] == true or self.leader == player
end

function Activity:IsPlayerBanned(player)
	return self.bannedSteamIds[player:GetSteamId().id] == true
end

function Activity:IsPlayerWhitelisted(player)
	return self.whitelistedSteamIds[player:GetSteamId().id] == true
end

function Activity:GetWhitelistedPlayers()
	local whitelist = {}

	for steamId, _ in pairs(self.whitelistedSteamIds) do
		local player = GroupActivitiesClient:SteamIdToPlayer(steamId)
		if player ~= nil then whitelist[player] = true end
	end

	return whitelist
end

function Activity:GetBannedPlayers()
	local banlist = {}

	for steamId, _ in pairs(self.bannedSteamIds) do
		local player = GroupActivitiesClient:SteamIdToPlayer(steamId)
		if player ~= nil then banlist[player] = true end
	end

	return banlist
end

function Activity:AddWhitelistedPlayer(player)
	self.whitelistedSteamIds[player:GetSteamId().id] = true
	self.bannedSteamIds[player:GetSteamId().id] = nil
end

function Activity:RemoveWhitelistedPlayer(player)
	self.whitelistedSteamIds[player:GetSteamId().id] = nil
end

function Activity:AddWhitelistedPlayers(addedPlayers)
	for player, _ in pairs(addedPlayers) do
		self:AddWhitelistedPlayer(player)
	end
end

function Activity:RemoveWhitelistedPlayers(removedPlayers)
	for player, _ in pairs(removedPlayers) do
		self:RemoveWhitelistedPlayer(player)
	end
end

function Activity:SetWhitelistedPlayers(whitelist)
	self.whitelistedSteamIds = {}

	self:AddWhitelistedPlayers(whitelist)
end

function Activity:AddBannedPlayer(player)
	self.bannedSteamIds[player:GetSteamId().id] = true
	self.whitelistedSteamIds[player:GetSteamId().id] = nil
end

function Activity:RemoveBannedPlayer(player)
	self.bannedSteamIds[player:GetSteamId().id] = nil
end

function Activity:AddBannedPlayers(addedPlayers)
	for player, _ in pairs(addedPlayers) do
		self:AddBannedPlayer(player)
	end
end

function Activity:RemoveBannedPlayers(removedPlayers)
	for player, _ in pairs(removedPlayers) do
		self:RemoveBannedPlayer(player)
	end
end

function Activity:SetBannedPlayers(banlist)
	self.bannedSteamIds = {}

	self:AddBannedPlayers(banlist)
end

function Activity:ToTable()
	local t = {}

	t.active = self.active
	t.id = self.id
	t.name = self.name
	t.description = self.description
	t.access = self.access
	t.password = self.password
	t.leader = self.leader
	t.onLeaveAction = self.onLeaveAction
	t.members = self.members
	t.bannedSteamIds = self.bannedSteamIds
	t.whitelistedSteamIds = self.whitelistedSteamIds
	t.allowedVehicles = self.allowedVehicles
	t.boost = self.boost

	return t
end

function Activity.FromTable(t)
	local self = Activity(t.id, t.name, t.leader)

	self.active = t.active
	self.description = t.description
	self.access = t.access
	self.password = t.password
	self.onLeaveAction = t.onLeaveAction
	self.members = t.members
	self.bannedSteamIds = t.bannedSteamIds
	self.whitelistedSteamIds = t.whitelistedSteamIds
	self.allowedVehicles = t.allowedVehicles
	self.boost = t.boost

	return self
end