class("PlayerSelector")(ActiveWindow)

function PlayerSelector:__init()
	ActiveWindow.__init(self)

	self.window:SetSize(Vector2(300, 600))
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
	self.window:SetTitle("Select a player")

	self.playerList = PlayerList.Create(self.window)
	self.playerList:SetDock(GwenPosition.Fill)
	self.playerList:Subscribe("RowSelected", self, self.OnRowSelected)

	self.finishButton = Button.Create(self.window)
	self.finishButton:SetDock(GwenPosition.Bottom)
	self.finishButton:SetWidthAutoRel(1.0)
	self.finishButton:SetHeight(25)
	self.finishButton:SetText("Finish")
	self.finishButton:SetEnabled(false)
	self.finishButton:Subscribe("Press", self, self.OnFinishButtonClick)
end

function PlayerSelector:OnRowSelected()
	self.finishButton:SetEnabled(true)
end

function PlayerSelector:OnFinishButtonClick()
	Events:Fire("PlayerPromoted", self.playerList:GetSelectedPlayer())
	self:Close()
end