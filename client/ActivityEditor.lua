class("ActivityEditor")(ActiveWindow)

function ActivityEditor:__init()
	ActiveWindow.__init(self)

	self.callback = callback
	self.activity = Activity(-1, "", LocalPlayer)

	self.window:SetWidthRel(0.2)
	self.window:SetHeight(450)
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
	self.window:SetTitle("Create a group activity")
	
	self.nameBox = LabeledTextBox.Create(self.window)
	self.nameBox:SetLabel("Name")
	self.nameBox:SetWidthAutoRel(1.0)
	self.nameBox:SetHeight(25)
	self.nameBox:Subscribe("TextChanged", self, self.OnFormChanged)

	self.descriptionBox = LabeledTextBoxMultiline.Create(self.window)
	self.descriptionBox:SetLabel("Description")
	self.descriptionBox:SetWidthAutoRel(1.0)
	self.descriptionBox:SetHeight(100)
	self.descriptionBox:SetPosition(Vector2(0, 30))

	local accessGroup = GroupBox.Create(self.window)
	accessGroup:SetWidthAutoRel(1.0)
	accessGroup:SetHeight(70)
	accessGroup:SetPosition(Vector2(0, 135))

	self.accessBox = ComboBox.Create(accessGroup)
	self.accessBox:SetWidthAutoRel(1.0)
	self.accessBox:SetPosition(Vector2(0, 0))
	self.accessBox:AddItem(Access.Public, Access.Public)
	self.accessBox:AddItem(Access.Password, Access.Password)
	self.accessBox:AddItem(Access.Whitelist, Access.Whitelist)
	self.accessBox:Subscribe("Selection", self, self.OnAccessBoxSelection)
	self.accessBox:Subscribe("Selection", self, self.OnFormChanged)

	self.passwordBox = LabeledTextBox.Create(accessGroup)
	self.passwordBox:SetWidthAutoRel(1.0)
	self.passwordBox:SetHeight(25)
	self.passwordBox:SetPosition(Vector2(0, 25))
	self.passwordBox:SetLabel("Password")
	self.passwordBox:SetVisible(false)
	self.passwordBox:Subscribe("TextChanged", self, self.OnFormChanged)

	self.whitelistButton = Button.Create(accessGroup)
	self.whitelistButton:SetWidthAutoRel(1.0)
	self.whitelistButton:SetHeight(25)
	self.whitelistButton:SetPosition(Vector2(0, 25))
	self.whitelistButton:SetText("Edit whitelist")
	self.whitelistButton:SetVisible(false)

	self.vehicleButton = Button.Create(self.window)
	self.vehicleButton:SetWidthAutoRel(1.0)
	self.vehicleButton:SetHeight(25)
	self.vehicleButton:SetPosition(Vector2(0, 210))
	self.vehicleButton:SetText("Edit allowed vehicles")

	self.banButton = Button.Create(self.window)
	self.banButton:SetWidthAutoRel(1.0)
	self.banButton:SetHeight(25)
	self.banButton:SetPosition(Vector2(0, 240))
	self.banButton:SetText("Ban/Unban players")

	self.onLeaveBase = BaseWindow.Create(self.window)
	self.onLeaveBase:SetPosition(Vector2(0, 270))
	self.onLeaveBase:SetWidthAutoRel(1.0)
	self.onLeaveBase:SetHeight(25)

	self.onLeaveLabel = Label.Create(self.onLeaveBase)
	self.onLeaveLabel:SetDock(GwenPosition.Left)
	self.onLeaveLabel:SetSizeAutoRel(Vector2(0.5, 1.0))
	self.onLeaveLabel:SetAlignment(GwenPosition.CenterV)
	self.onLeaveLabel:SetText("When the leader leaves ")

	self.onLeaveBox = ComboBox.Create(self.onLeaveBase)
	self.onLeaveBox:SetDock(GwenPosition.Right)
	self.onLeaveBox:SetSizeAutoRel(Vector2(0.5, 1.0))
	self.onLeaveBox:SetAlignment(GwenPosition.CenterV)
	self.onLeaveBox:AddItem(OnLeaveAction.Promote, OnLeaveAction.Promote)
	self.onLeaveBox:AddItem(OnLeaveAction.Delete, OnLeaveAction.Delete)

	self.promoteButton = Button.Create(self.window)
	self.promoteButton:SetWidthAutoRel(1.0)
	self.promoteButton:SetHeight(25)
	self.promoteButton:SetPosition(Vector2(0, 300))
	self.promoteButton:SetText("Promote player to leader")
	self.promoteButton:Subscribe("Press", self, self.OnPromoteButtonClick)
	self.promoteButton:Hide()
	self.promoteEvent = Events:Subscribe("PlayerPromoted", self, self.OnPlayerPromoted)

	self.deleteButton = Button.Create(self.window)
	self.deleteButton:SetWidthAutoRel(1.0)
	self.deleteButton:SetHeight(25)
	self.deleteButton:SetPosition(Vector2(0, 330))
	self.deleteButton:SetText("Delete this activity")
	self.deleteButton:Subscribe("Press", self, self.OnDeleteButtonClick)
	self.deleteButton:Hide()

	self.saveButton = Button.Create(self.window)
	self.saveButton:SetWidthAutoRel(1.0)
	self.saveButton:SetHeight(25)
	self.saveButton:SetDock(GwenPosition.Bottom)
	self.saveButton:SetText("Save")
	self.saveButton:SetEnabled(false)
	self.saveButton:Subscribe("Press", self, self.OnSaveButtonClick)
	self.saveButton:SetToolTip("Activity name and/or password missing")
end

function ActivityEditor:SetActivity(activity)
	self.window:SetTitle("Edit group activity")
	self.activity = activity
	self.promoteButton:Show()
	self.deleteButton:Show()
	self.nameBox:SetText(activity.name)
	self.descriptionBox:SetText(activity.description)
	self.accessBox:SelectItemByName(activity.access)
	self.passwordBox:SetText(activity.password)
	self.onLeaveBox:SelectItemByName(activity.onLeaveAction)
end

function ActivityEditor:OnFormChanged(box)
	if self.nameBox:GetText() ~= "" and ((self.accessBox:GetSelectedItem():GetText() == Access.Password and self.passwordBox:GetText() ~= "") or self.accessBox:GetSelectedItem():GetText() ~= Access.Password) then
		self.saveButton:SetEnabled(true)
		self.saveButton:SetToolTip("Save your new activity")
	else
		self.saveButton:SetEnabled(false)
		self.saveButton:SetToolTip("Activity name and/or password missing")
	end
end

function ActivityEditor:OnAccessBoxSelection(box)
	if box:GetSelectedItem():GetText() == Access.Password then
		self.whitelistButton:SetVisible(false)
		self.passwordBox:SetVisible(true)
	elseif box:GetSelectedItem():GetText() == Access.Whitelist then
		self.whitelistButton:SetVisible(true)
		self.passwordBox:SetVisible(false)
	else
		self.whitelistButton:SetVisible(false)
		self.passwordBox:SetVisible(false)
	end
end

function ActivityEditor:OnPromoteButtonClick()
	if self.promoteWindow == nil or not self.promoteWindow.active then
		self.promoteWindow = PlayerSelector()
		self.promoteWindow.window:SetTitle("Select player from this activity to promote")
		self.promoteWindow.playerList:SetPlayers(self.members)
	end
end

function ActivityEditor:OnPlayerPromoted(player)
	PromotePlayer(self.activity, player)
	self:Close()
end

function ActivityEditor:Close()
	if self.active then
		Events:Unsubscribe(self.promoteEvent)
	end
	if self.promoteWindow ~= nil then self.promoteWindow:Close() end
	ActiveWindow.Close(self)
end

function ActivityEditor:OnSaveButtonClick()
	self.activity.name = self.nameBox:GetText()
	self.activity.description = self.descriptionBox:GetText()
	self.activity.access = self.accessBox:GetSelectedItem():GetText()
	self.activity.password = self.passwordBox:GetText()
	self.activity.onLeaveAction = self.onLeaveBox:GetSelectedItem():GetText()

	SaveActivity(self.activity)

	self:Close()
end

function ActivityEditor:OnDeleteButtonClick()
	DeleteActivity(self.activity)

	self:Close()
end