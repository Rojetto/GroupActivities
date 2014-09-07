Access = {}
Access.Public = "Public"
Access.Password = "Password"
Access.Whitelist = "Whitelist"

class("Activity")

function Activity:__init(activityId, name, leader)
	self.active = true
	self.id = activityId
	self.name = name
	self.description = ""
	self.access = Access.Public
	self.password = ""
	self.leader = leader
	self.members = {}
	self.bannedSteamIds = {}
	self.whitelistedSteamIds = {}
	self.allowedVehicles = {}
end

function Activity:PlayerJoin(player)
	self.members[player] = true
end

function Activity:PlayerQuit(player)
	self.members[player] = nil
	if self.leader == player then
		if #self.members == 0 then
			--TODO: this activity has to be removed
			self.active = false
		else
			local key, value = next(self.members)
			self.leader = key
			self.members[key] = nil
		end
	end
end

function Activity:IsVehicleAllowed(vehicleId)
	return self.allowedVehicles[vehicleId] ~= nil
end

function Activity:IsPlayerInActivity(player)
	return self.members[player] ~= nil or self.leader == player
end

function Activity:IsPlayerBanned(player)
	return self.bannedSteamIds[player:GetSteamId()] ~= nil
end

function Activity:IsPlayerWhitelisted(player)
	return self.whitelistedSteamIds[player:GetSteamId()] ~= nil
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
	t.members = self.members
	t.bannedSteamIds = self.bannedSteamIds
	t.whitelistedSteamIds = self.whitelistedSteamIds
	t.allowedVehicles = self.allowedVehicles

	return t
end

function Activity.FromTable(t)
	local self = Activity(t.id, t.name, t.leader)

	self.active = t.active
	self.description = t.description
	self.access = t.access
	self.password = t.password
	self.members = t.members
	self.bannedSteamIds = t.bannedSteamIds
	self.whitelistedSteamIds = t.whitelistedSteamIds
	self.allowedVehicles = t.allowedVehicles

	return self
end