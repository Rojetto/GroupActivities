class("ActivityBrowser")

function ActivityBrowser:__init()
	self.active = true

	self.window = Window.Create()
	self.window:SetTitle("Group Activities by Rojetto")
	self.window:SetSize(Vector2(1000, 550))
	self.window:SetMinimumSize(Vector2(600, 550))
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
	self.window:Subscribe("WindowClosed", self, self.OnWindowClosed)

	self.browserBase = BaseWindow.Create(self.window)
	self.browserBase:SetDock(GwenPosition.Fill)
	self.browserBase:SetSizeAutoRel(Vector2(1.0, 1.0))

	self.activityList = SortedList.Create(self.browserBase)
	self.activityList:SetDock(GwenPosition.Left)
	self.activityList:SetWidthAutoRel(0.7)
	self.activityList:SetPadding(Vector2(0, 0), Vector2(0, 5))
	self.activityList:AddColumn("Id", 64)
	self.activityList:AddColumn("Name")
	self.activityList:AddColumn("Leader")
	self.activityList:AddColumn("Access", 128)
	self.activityList:AddColumn("Players", 64)
	self.activityList:Subscribe("RowSelected", self, self.OnRowSelected)

	self.details = BaseWindow.Create(self.browserBase)
	self.details:SetWidthAutoRel(0.3)
	self.details:SetDock(GwenPosition.Right)
	self.details:SetPadding(Vector2(5, 0), Vector2(0, 5))

	self.detailsGroup = GroupBox.Create(self.details)
	self.detailsGroup:SetDock(GwenPosition.Fill)

	self.detailsButtons = BaseWindow.Create(self.details)
	self.detailsButtons:SetDock(GwenPosition.Bottom)
	self.detailsButtons:SetWidthAutoRel(1.0)
	self.detailsButtons:SetHeight(85)
	self.detailsButtons:SetPadding(Vector2(0, 5), Vector2(0, 0))

	self.nameLabel = Label.Create(self.detailsGroup)
	self.nameLabel:SetHeight(25)
	self.nameLabel:SetWidthAutoRel(1.0)

	self.leaderLabel = Label.Create(self.detailsGroup)
	self.leaderLabel:SetHeight(25)
	self.leaderLabel:SetWidthAutoRel(1.0)
	self.leaderLabel:SetPosition(Vector2(0, 30))

	self.accessLabel = Label.Create(self.detailsGroup)
	self.accessLabel:SetHeight(25)
	self.accessLabel:SetWidthAutoRel(1.0)
	self.accessLabel:SetPosition(Vector2(0, 60))

	self.boostLabel = Label.Create(self.detailsGroup)
	self.boostLabel:SetHeight(25)
	self.boostLabel:SetWidthAutoRel(1.0)
	self.boostLabel:SetPosition(Vector2(0, 90))

	self.playersLabel = Label.Create(self.detailsGroup)
	self.playersLabel:SetHeight(25)
	self.playersLabel:SetWidthAutoRel(1.0)
	self.playersLabel:SetPosition(Vector2(0, 120))

	self.descriptionScrollControl = ScrollControl.Create(self.detailsGroup)
	self.descriptionScrollControl:SetWidthAutoRel(1.0)
	self.descriptionScrollControl:SetHeight(100)
	self.descriptionScrollControl:SetPosition(Vector2(0, 150))

	self.descriptionBox = TextBoxMultiline.Create(self.descriptionScrollControl)
	self.descriptionBox:SetEnabled(false)
	self.descriptionBox:SetHeight(100)
	self.descriptionBox:SetWidthAutoRel(0.95)

	self.playerList = PlayerList.Create(self.detailsGroup)
	self.playerList:SetHeight(100)
	self.playerList:SetWidthAutoRel(1.0)
	self.playerList:SetPosition(Vector2(0, 255))

	self.vehiclesButton = Button.Create(self.detailsGroup)
	self.vehiclesButton:SetHeight(25)
	self.vehiclesButton:SetWidthAutoRel(1.0)
	self.vehiclesButton:SetPosition(Vector2(0, 360))
	self.vehiclesButton:SetText("Show allowed vehicles")
	self.vehiclesButton:Subscribe("Press", self, self.OnVehiclesButtonClick)

	self.arrowLabel = Label.Create(self.detailsButtons)
	self.arrowLabel:SetText("Show arrow to leader")
	self.arrowLabel:SizeToContents()
	self.arrowLabel:SetHeight(25)
	self.arrowLabel:SetAlignment(GwenPosition.CenterV)

	self.arrowBox = CheckBox.Create(self.detailsButtons)
	self.arrowBox:SetPosition(Vector2(150, 5))
	self.arrowBox:SetChecked(true)

	self.teleportButton = Button.Create(self.detailsButtons)
	self.teleportButton:SetPosition(Vector2(0, 30))
	self.teleportButton:SetHeight(25)
	self.teleportButton:SetWidthAutoRel(1.0)
	self.teleportButton:SetText("Teleport to leader")
	self.teleportButton:Subscribe("Press", self, self.OnTeleportButtonClick)

	self.joinLeaveButton = Button.Create(self.detailsButtons)
	self.joinLeaveButton:SetPosition(Vector2(0, 60))
	self.joinLeaveButton:SetHeight(25)
	self.joinLeaveButton:SetWidthAutoRel(1.0)
	self.joinLeaveButton:Subscribe("Press", self, self.OnJoinLeaveButtonClicked)

	self.createEditButton = Button.Create(self.window)
	self.createEditButton:SetDock(GwenPosition.Bottom)
	self.createEditButton:SetWidthAutoRel(1.0)
	self.createEditButton:SetHeight(25)
	self.createEditButton:SetText("Create activity")
	self.createEditButton:Subscribe("Press", self, self.OnCreateEditButtonClicked)

	self.activities = {}

	Events:Subscribe("LocalPlayerInput", self, self.OnLocalPlayerInput)
	Events:Subscribe("Render", self, self.OnRender)

	self:ShowDetails(nil)
end

function ActivityBrowser:SetActivities(activityList)
	self.activities = activityList
	self.activityList:Clear()
	local selectedRow = nil
	for id, activity in pairs(activityList) do
		local row = self.activityList:AddItem(tostring(activity.id))
		row:SetCellText(1, activity.name)
		row:SetCellText(2, Player.GetById(activity.leaderId):GetName())
		row:SetCellText(3, activity.access)
		row:SetCellText(4, tostring(#(activity.memberIds) + 1))

		if GroupActivitiesClient:GetJoinedActivity(LocalPlayer) ~= nil and id == GroupActivitiesClient:GetJoinedActivity(LocalPlayer).id then
			row:SetTextColor(Color(0, 255, 0))
			selectedRow = row
		end
	end

	if selectedRow ~= nil then
		self.activityList:SetSelectRow(selectedRow)
	else
		self:ShowDetails(nil)
	end

	if GroupActivitiesClient:GetJoinedActivity(LocalPlayer) == nil then
		self.createEditButton:SetText("Create activity")
		self.createEditButton:SetToolTip("Create a new activity")
		self.createEditButton:SetEnabled(true)
	else
		if GroupActivitiesClient:GetJoinedActivity(LocalPlayer).leaderId == LocalPlayer:GetId() then
			self.createEditButton:SetText("Edit activity")
			self.createEditButton:SetToolTip("Edit your activity settings")
			self.createEditButton:SetEnabled(true)
		else
			self.createEditButton:SetText("Create activity")
			self.createEditButton:SetToolTip("You have to leave your activity before you can create a new one")
			self.createEditButton:SetEnabled(false)
		end
	end
end

function ActivityBrowser:OnWindowClosed()
	self:SetActive(false)
end

function ActivityBrowser:OnLocalPlayerInput()
	Mouse:SetVisible(self.active and self.window:GetVisible())
	return not self.active
end

function ActivityBrowser:OnRender()
	if self.window:GetVisible() and Game:GetState() ~= GUIState.Game then
		self.window:Hide()
	end
	if self.active and not self.window:GetVisible() and Game:GetState() == GUIState.Game then
		self.window:Show()
	end
end

function ActivityBrowser:SetActive(active)
	self.active = active
	if active then
		self.window:Show()
	else
		self.window:Hide()
		if self.editor ~= nil then self.editor:Close() end
		if self.passwordWindow ~= nil then self.passwordWindow:Close() end
		if self.vehicleWindow ~= nil then self.vehicleWindow:Close() end
	end
end

function ActivityBrowser:OnRowSelected()
	local activity = self:GetSelectedActivity()
	self:ShowDetails(activity)
end

function ActivityBrowser:IsActivityChatEnabled()
	return self.chatBox:GetChecked()
end

function ActivityBrowser:IsArrowEnabled()
	return self.arrowBox:GetChecked()
end

function ActivityBrowser:ShowDetails(activity)
	self.nameLabel:SetText("Name: ")
	self.leaderLabel:SetText("Leader: ")
	self.accessLabel:SetText("Access: ")
	self.boostLabel:SetText("Boost allowed: ")
	self.playersLabel:SetText("Players: ")
	self.descriptionBox:SetText("No description")
	self.descriptionBox:SetHeight(100)
	self.playerList:SetPlayers({})

	self.vehiclesButton:SetEnabled(false)
	self.teleportButton:SetEnabled(false)
	self.joinLeaveButton:SetText("Join")
	self.joinLeaveButton:SetToolTip("You need to select an activity")
	self.joinLeaveButton:SetEnabled(false)

	if activity ~= nil then
		self.nameLabel:SetText("Name: "..activity.name)
		self.leaderLabel:SetText("Leader: "..Player.GetById(activity.leaderId):GetName())
		self.accessLabel:SetText("Access: "..activity.access)
		self.playersLabel:SetText("Players: "..(#(activity.memberIds) + 1))
		self.boostLabel:SetText("Boost allowed: " .. (activity.boost and "yes" or "no"))

		self.vehiclesButton:SetEnabled(true)
		self.teleportButton:SetEnabled(true)

		if activity.description ~= "" then
			self.descriptionBox:SetText(activity.description)
			self.descriptionBox:SizeToContents()
			if self.descriptionBox:GetHeight() < 100 then
				self.descriptionBox:SetHeight(100)
			end
			self.descriptionBox:SetWidthAutoRel(0.95)
		end

		local memberList = {}
		for memberId, _ in pairs(activity.memberIds) do
			memberList[Player.GetById(memberId)] = true
		end
		self.playerList:SetPlayers(memberList)

		if GroupActivitiesClient:GetJoinedActivity(LocalPlayer) == nil or GroupActivitiesClient:GetJoinedActivity(LocalPlayer).id ~= activity.id then
			if activity.access == Access.Whitelist and not activity:IsPlayerWhitelisted(LocalPlayer) then
				self.joinLeaveButton:SetToolTip("You are not on the whitelist")
			elseif activity:IsPlayerBanned(LocalPlayer) then
				self.joinLeaveButton:SetToolTip("You are banned from this activity")
			elseif GroupActivitiesClient:GetJoinedActivity(LocalPlayer) ~= nil then
				self.joinLeaveButton:SetToolTip("You have to leave the activity you are currently in first")
			else
				self.joinLeaveButton:SetEnabled(true)
				self.joinLeaveButton:SetText("Join")
				self.joinLeaveButton:SetToolTip("Join this activity")
			end
		else
			self.joinLeaveButton:SetEnabled(true)
			self.joinLeaveButton:SetText("Leave")
			self.joinLeaveButton:SetToolTip("Leave this activity")
		end
	end
end

function ActivityBrowser:OnCreateEditButtonClicked()
	if self.editor == nil or not self.editor.active then
		self.editor = ActivityEditor()
		if GroupActivitiesClient:GetJoinedActivity(LocalPlayer) ~= nil and GroupActivitiesClient:GetJoinedActivity(LocalPlayer).leaderId == LocalPlayer:GetId() then
			self.editor:SetActivity(GroupActivitiesClient:GetJoinedActivity(LocalPlayer))
		end
	end
end

function ActivityBrowser:OnVehiclesButtonClick()
	if self.vehicleWindow == nil or not self.vehicleWindow.active then
		self.vehicleWindow = AllowedVehiclesEditor(false, nil, nil)
		self.vehicleWindow:SetAllowedVehicles(self:GetSelectedActivity().allowedVehicles)
	end
end

function ActivityBrowser:OnTeleportButtonClick()
	GroupActivitiesClient:TeleportToLeader()
	self:SetActive(false)
end

function ActivityBrowser:OnJoinLeaveButtonClicked()
	if GroupActivitiesClient:GetJoinedActivity(LocalPlayer) == self:GetSelectedActivity() then
		GroupActivitiesClient:LeaveActivity(self:GetSelectedActivity())
	else
		if (self:GetSelectedActivity().access ~= Access.Password) then
			GroupActivitiesClient:JoinActivity(self:GetSelectedActivity())
		else
			if self.passwordWindow == nil or not self.passwordWindow.active then
				self.passwordWindow = PasswordWindow(self:GetSelectedActivity(), self, self.OnPasswordEntered)
			end
		end
	end
end

function ActivityBrowser:OnPasswordEntered(activity)
	GroupActivitiesClient:JoinActivity(activity)
end

function ActivityBrowser:GetSelectedActivity()
	return self.activities[tonumber(self.activityList:GetSelectedRow():GetCellText(0))]
end