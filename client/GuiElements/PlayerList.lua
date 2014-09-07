class("PlayerList")(BaseWindow)

function PlayerList.Create(baseWindow)
	local self = BaseWindow.Create(baseWindow)

	self.SetPlayers = PlayerList.SetPlayers
	self.SetMultiSelect = PlayerList.SetMultiSelect
	self.GetMultiSelect = PlayerList.GetMultiSelect
	self.GetSelectedPlayer = PlayerList.GetSelectedPlayer

	self.sortedList = SortedList.Create(self)
	self.sortedList:SetDock(GwenPosition.Fill)
	self.sortedList:AddColumn("Id", 64)
	self.sortedList:AddColumn("Name")

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

	self.sortedList:Clear()
	for player, _ in pairs(players) do
		local row = self.sortedList:AddItem(tostring(player:GetId()))
		row:SetCellText(1, player:GetName())
	end
end

function PlayerList:SetMultiSelect(multiSelect)
	self.sortedList:SetMultiSelect(multiSelect)
end

function PlayerList:GetMultiSelect()
	return self.sortedList:GetMultiSelect()
end

function PlayerList:GetSelectedPlayer()
	local row = self.sortedList:GetSelectedRow()
	for player, _ in pairs(self.players) do
		if player:GetId() == tonumber(row:GetCellText(0)) then
			return player
		end
	end
end