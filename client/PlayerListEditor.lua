class("PlayerListEditor")(ActiveWindow)

function PlayerListEditor:__init(originalList, callbackObject, callbackFunction)
	ActiveWindow.__init(self)

	self.originalList = originalList
	self.callbackObject = callbackObject
	self.callbackFunction = callbackFunction

	self.window:SetSize(Vector2(300, 600))
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
	self.window:SetTitle("Edit the list")

	self.playerList = PlayerList.Create(self.window)
	self.playerList:SetDock(GwenPosition.Fill)
	self.playerList:SetPadding(Vector2(0, 0), Vector2(0, 5))
	self.playerList:Subscribe("RowSelected", self, self.OnRowSelected)

	self.bottomBase = BaseWindow.Create(self.window)
	self.bottomBase:SetDock(GwenPosition.Bottom)
	self.bottomBase:SetWidthAutoRel(1.0)
	self.bottomBase:SetHeight(55)

	self.addRemoveBase = BaseWindow.Create(self.bottomBase)
	self.addRemoveBase:SetWidthAutoRel(1.0)
	self.addRemoveBase:SetHeight(25)

	self.addButton = Button.Create(self.addRemoveBase)
	self.addButton:SetSizeAutoRel(Vector2(0.5, 1.0))
	self.addButton:SetText("Add player")
	self.addButton:Subscribe("Press", self, self.OnAddButtonClick)

	self.removeButton = Button.Create(self.addRemoveBase)
	self.removeButton:SetDock(GwenPosition.Right)
	self.removeButton:SetSizeAutoRel(Vector2(0.5, 1.0))
	self.removeButton:SetText("Remove player")
	self.removeButton:Subscribe("Press", self, self.OnRemoveButtonClick)
	self.removeButton:SetEnabled(false)

	self.finishButton = Button.Create(self.bottomBase)
	self.finishButton:SetDock(GwenPosition.Bottom)
	self.finishButton:SetWidthAutoRel(1.0)
	self.finishButton:SetHeight(25)
	self.finishButton:SetText("Save")
	self.finishButton:Subscribe("Press", self, self.OnFinishButtonClick)

	local listCopy = {}
	for key, value in pairs(self.originalList) do listCopy[key] = value end
	self.playerList:SetPlayers(listCopy)
end

function PlayerListEditor:OnRowSelected()
	self.removeButton:SetEnabled(true)
end

function PlayerListEditor:OnAddButtonClick()
	if self.addWindow == nil or not self.addWindow.active then
		self.addWindow = PlayerSelector(self, self.OnPlayerAdded)
		self.addWindow.window:SetTitle("Select player to add to list")
	end
end

function PlayerListEditor:OnRemoveButtonClick()
	if self.playerList:GetSelectedPlayer() ~= nil then
		local newList = self.playerList.players
		newList[self.playerList:GetSelectedPlayer()] = nil
		self.playerList:SetPlayers(newList)
	end
end

function PlayerListEditor:GetAddedPlayers()
	local addedPlayers = {}

	for player, _ in pairs(self.playerList.players) do
		if self.originalList[player] == nil then
			addedPlayers[player] = true
		end
	end

	return addedPlayers
end

function PlayerListEditor:GetRemovedPlayers()
	local removedPlayers = {}

	for player, _ in pairs(self.originalList) do
		if self.playerList.players[player] == nil then
			removedPlayers[player] = true
		end
	end

	return removedPlayers
end

function PlayerListEditor:OnFinishButtonClick()
	self.callbackFunction(self.callbackObject, self.playerList.players, self:GetAddedPlayers(), self:GetRemovedPlayers())

	self:Close()
end

function PlayerListEditor:OnPlayerAdded(player)
	local newList = self.playerList.players
	newList[player] = true
	self.playerList:SetPlayers(newList)
end

function PlayerListEditor:Close()
	if self.addWindow ~= nil then self.addWindow:Close() end
	ActiveWindow.Close(self)
end