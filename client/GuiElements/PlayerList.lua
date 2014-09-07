class("PlayerList")(SortedList)

function PlayerList.Create(baseWindow)
	local self = SortedList.Create(baseWindow)

	self.SetPlayers = PlayerList.SetPlayers
	self.GetSelectedPlayer = PlayerList.GetSelectedPlayer

	self:AddColumn("Id", 64)
	self:AddColumn("Name")

	self.players = {}

	local playerTable = {}
	for player in Client:GetPlayers() do
		playerTable[player] = true
	end
	playerTable[LocalPlayer] = true
	self:SetPlayers(playerTable)

	return self
end

function PlayerList:SetPlayers(players)
	self.players = players

	self:Clear()
	for player, _ in pairs(players) do
		local row = self:AddItem(tostring(player:GetId()))
		row:SetCellText(1, player:GetName())
	end
end

function PlayerList:GetSelectedPlayer()
	local row = self:GetSelectedRow()
	for player, _ in pairs(self.players) do
		if player:GetId() == tonumber(row:GetCellText(0)) then
			return player
		end
	end
end