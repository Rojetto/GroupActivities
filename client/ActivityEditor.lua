class("ActivityEditor")

function ActivityEditor:__init(callback)
	self.callback = callback

	self.active = true

	self.activity = Activity(-1, "", LocalPlayer)

	self.window = Window.Create()
	self.window:SetWidthRel(0.2)
	self.window:SetHeight(380)
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
	self.window:SetTitle("Create a group activity")
	self.window:Subscribe("WindowClosed", self, self.Close)
	
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

	self.promoteButton = Button.Create(self.window)
	self.promoteButton:SetWidthAutoRel(1.0)
	self.promoteButton:SetHeight(25)
	self.promoteButton:SetPosition(Vector2(0, 240))
	self.promoteButton:SetText("Promote player to leader")

	self.banButton = Button.Create(self.window)
	self.banButton:SetWidthAutoRel(1.0)
	self.banButton:SetHeight(25)
	self.banButton:SetPosition(Vector2(0, 270))
	self.banButton:SetText("Ban/Unban players")

	self.saveButton = Button.Create(self.window)
	self.saveButton:SetWidthAutoRel(1.0)
	self.saveButton:SetHeight(25)
	self.saveButton:SetDock(GwenPosition.Bottom)
	self.saveButton:SetText("Save")
	self.saveButton:SetEnabled(false)
	self.saveButton:Subscribe("Press", self, self.OnSaveButtonClick)
	self.saveButton:SetToolTip("Activity name and/or password missing")

	self.window:Show()

	self.inputEvent = Events:Subscribe("LocalPlayerInput", self, self.OnLocalPlayerInput)
end

function ActivityEditor:SetActivity(activity)
	self.window:SetTitle("Edit group activity")
	self.activity = activity
	self.nameBox:SetText(activity.name)
	self.descriptionBox:SetText(activity.description)
	self.accessBox:SelectItemByName(activity.access)
	self.passwordBox:SetText(activity.password)
end

function ActivityEditor:OnLocalPlayerInput()
	Mouse:SetVisible(self.active)
	return not self.active
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

function ActivityEditor:OnSaveButtonClick()
	self.activity.name = self.nameBox:GetText()
	self.activity.description = self.descriptionBox:GetText()
	self.activity.access = self.accessBox:GetSelectedItem():GetText()
	self.activity.password = self.passwordBox:GetText()

	self.callback(self.activity)

	self:Close()
end

function ActivityEditor:Close()
	self.active = false
	self.window:Hide()
	Events:Unsubscribe(self.inputEvent)
end