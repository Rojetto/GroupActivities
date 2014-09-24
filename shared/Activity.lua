Access = {}
Access.Public = "Public"
Access.Password = "Password"
Access.Whitelist = "Whitelist"

OnLeaveAction = {}
OnLeaveAction.Delete = "Delete activity"
OnLeaveAction.Promote = "Promote a random player"

class("Activity")

function Activity:__init(activityId, name, leaderId)
	self.active = true
	self.id = activityId
	self.name = name
	self.description = ""
	self.access = Access.Public
	self.password = ""
	self.leaderId = leaderId
	self.onLeaveAction = OnLeaveAction.Promote
	self.memberIds = {}
	self.bannedSteamIds = {}
	self.whitelistedSteamIds = {}
	self.allowedVehicles = {}
	for id = 1, 92, 1 do
		self.allowedVehicles[id] = true
	end
	self.boost = true
end

function Activity:PlayerJoin(player)
	local playerId = player:GetId()
	if not self:IsPlayerInActivity(player) then
		self.memberIds[player:GetId()] = true
		Chat:Send(player, 'You have joined "' .. self.name .. '"', Color(0, 255, 0))
		Chat:Send(player, "You're now talking in the activity chat. Leave the activity to return to global chat.", Color(255, 255, 0))
	end
end

function Activity:PlayerQuit(player)
	local playerId = player:GetId()
	if self:IsPlayerInActivity(player) then
		self.memberIds[playerId] = nil
		if self.leaderId == playerId then
			if self.onLeaveAction == OnLeaveAction.Delete then
				self.active = false
			elseif self.onLeaveAction == OnLeaveAction.Promote then
				if #(self.memberIds) == 0 then
					self.active = false
				else
					local key, value = next(self.memberIds)
					self.leaderId = key
					self.memberIds[key] = nil
					Chat:Send(Player.GetById(key), 'You were promoted to the leader of "' .. self.name .. '"', Color(0, 255, 0))
				end
			end
		end
		Chat:Send(player, 'You have left "' .. self.name .. '"', Color(0, 255, 0))
		Chat:Send(player, "You're now talking in the global chat.", Color(255, 255, 0))
	end
end

function Activity:PromotePlayer(player)
	local playerId = player:GetId()
	if self:IsPlayerInActivity(player) then
		self.memberIds[self.leaderId] = true
		self.memberIds[playerId] = nil
		self.leaderId = playerId
		Chat:Send(player, 'You were promoted to the leader of "' .. self.name .. '"', Color(0, 255, 0))
	end
end

function Activity:Delete()
	for memberId, _ in pairs(self.memberIds) do
		local player = Player.GetById(memberId)
		Chat:Send(player, "The activity has been deleted", Color(0, 255, 0))
		self:PlayerQuit(player)
	end
	Chat:Send(Player.GetById(self.leaderId), "The activity has been deleted", Color(0, 255, 0))
	self:PlayerQuit(Player.GetById(self.leaderId))
end

function Activity:IsVehicleAllowed(vehicleId)
	return self.allowedVehicles[vehicleId]
end

function Activity:IsPlayerInActivity(player)
	local playerId = player:GetId()
	return self.memberIds[playerId] == true or self.leaderId == playerId
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
		local player = SteamIdToPlayer(steamId)
		if player ~= nil then whitelist[player] = true end
	end

	return whitelist
end

function Activity:GetBannedPlayers()
	local banlist = {}

	for steamId, _ in pairs(self.bannedSteamIds) do
		local player = SteamIdToPlayer(steamId)
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
	t.leaderId = self.leaderId
	t.onLeaveAction = self.onLeaveAction
	t.memberIds = self.memberIds
	t.bannedSteamIds = self.bannedSteamIds
	t.whitelistedSteamIds = self.whitelistedSteamIds
	t.allowedVehicles = self.allowedVehicles
	t.boost = self.boost

	return t
end

function Activity.FromTable(t)
	local self = Activity(t.id, t.name, t.leaderId)

	self.active = t.active
	self.description = t.description
	self.access = t.access
	self.password = t.password
	self.onLeaveAction = t.onLeaveAction
	self.memberIds = t.memberIds
	self.bannedSteamIds = t.bannedSteamIds
	self.whitelistedSteamIds = t.whitelistedSteamIds
	self.allowedVehicles = t.allowedVehicles
	self.boost = t.boost

	return self
end