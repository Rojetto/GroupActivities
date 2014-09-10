class("ActivityBrowser")

function ActivityBrowser:__init()
	self.active = true

	self.window = Window.Create()
	self.window:SetTitle("Group Activities")
	self.window:SetSizeRel(Vector2(0.5, 0.5))
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
	self.detailsButtons:SetHeight(55)
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

	self.playersLabel = Label.Create(self.detailsGroup)
	self.playersLabel:SetHeight(25)
	self.playersLabel:SetWidthAutoRel(1.0)
	self.playersLabel:SetPosition(Vector2(0, 90))

	self.descriptionScrollControl = ScrollControl.Create(self.detailsGroup)
	self.descriptionScrollControl:SetWidthAutoRel(1.0)
	self.descriptionScrollControl:SetHeight(100)
	self.descriptionScrollControl:SetPosition(Vector2(0, 120))

	self.descriptionBox = TextBoxMultiline.Create(self.descriptionScrollControl)
	self.descriptionBox:SetEnabled(false)
	self.descriptionBox:SetHeight(100)
	self.descriptionBox:SetWidthAutoRel(0.95)

	self.playerList = PlayerList.Create(self.detailsGroup)
	self.playerList:SetHeight(100)
	self.playerList:SetWidthAutoRel(1.0)
	self.playerList:SetPosition(Vector2(0, 225))

	self.teleportButton = Button.Create(self.detailsButtons)
	self.teleportButton:SetHeight(25)
	self.teleportButton:SetWidthAutoRel(1.0)
	self.teleportButton:SetText("Teleport to leader")
	self.teleportButton:Subscribe("Press", self, self.OnTeleportButtonClick)

	self.joinLeaveButton = Button.Create(self.detailsButtons)
	self.joinLeaveButton:SetDock(GwenPosition.Bottom)
	self.joinLeaveButton:SetHeight(25)
	self.joinLeaveButton:Subscribe("Press", self, self.OnJoinLeaveButtonClicked)

	self.createEditButton = Button.Create(self.window)
	self.createEditButton:SetDock(GwenPosition.Bottom)
	self.createEditButton:SetWidthAutoRel(1.0)
	self.createEditButton:SetHeight(25)
	self.createEditButton:SetText("Create activity")
	self.createEditButton:Subscribe("Press", self, self.OnCreateEditButtonClicked)

	self.activities = {}

	Events:Subscribe("LocalPlayerInput", self, self.OnLocalPlayerInput)

	self:ShowDetails(nil)
end

function ActivityBrowser:SetActivities(activityList)
	self.activities = activityList
	self.activityList:Clear()
	local selectedRow = nil
	for id, activity in pairs(activityList) do
		local row = self.activityList:AddItem(tostring(activity.id))
		row:SetCellText(1, activity.name)
		row:SetCellText(2, activity.leader:GetName())
		row:SetCellText(3, activity.access)
		row:SetCellText(4, tostring(#(activity.members) + 1))

		if id == GroupActivitiesClient:GetJoinedActivity().id then
			row:SetTextColor(Color(0, 255, 0))
			selectedRow = row
		end
	end

	if selectedRow ~= nil then
		self.activityList:SetSelectRow(selectedRow)
	else
		self:ShowDetails(nil)
	end

	if GroupActivitiesClient:GetJoinedActivity() == nil then
		self.createEditButton:SetText("Create activity")
		self.createEditButton:SetToolTip("Create a new activity")
	else
		if GroupActivitiesClient:GetJoinedActivity().leader == LocalPlayer then
			self.createEditButton:SetText("Edit activity")
			self.createEditButton:SetToolTip("Edit your activity settings")
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
	Mouse:SetVisible(self.active)
	return not self.active
end

function ActivityBrowser:SetActive(active)
	self.active = active
	if active then
		self.window:Show()
	else
		self.window:Hide()
		if self.editor ~= nil then self.editor:Close() end
	end
end

function ActivityBrowser:OnRowSelected()
	local activity = self:GetSelectedActivity()
	self:ShowDetails(activity)
end

function ActivityBrowser:ShowDetails(activity)
	self.nameLabel:SetText("Name: ")
	self.leaderLabel:SetText("Leader: ")
	self.accessLabel:SetText("Access: ")
	self.playersLabel:SetText("Players: ")
	self.descriptionBox:SetText("No description")
	self.descriptionBox:SetHeight(100)
	self.playerList:SetPlayers({})

	self.teleportButton:SetEnabled(false)
	self.joinLeaveButton:SetText("Join")
	self.joinLeaveButton:SetToolTip("You need to select an activity")
	self.joinLeaveButton:SetEnabled(false)

	if activity ~= nil then
		self.nameLabel:SetText("Name: "..activity.name)
		self.leaderLabel:SetText("Leader: "..activity.leader:GetName())
		self.accessLabel:SetText("Access: "..activity.access)
		self.playersLabel:SetText("Players: "..(#(activity.members) + 1))

		self.teleportButton:SetEnabled(true)

		if activity.description ~= "" then
			self.descriptionBox:SetText(activity.description)
			self.descriptionBox:SizeToContents()
			if self.descriptionBox:GetHeight() < 100 then
				self.descriptionBox:SetHeight(100)
			end
			self.descriptionBox:SetWidthAutoRel(0.95)
		end

		self.playerList:SetPlayers(activity.members)

		if GroupActivitiesClient:GetJoinedActivity() == nil or GroupActivitiesClient:GetJoinedActivity().id ~= activity.id then
			if activity.access == Access.Whitelist and not activity:IsPlayerWhitelisted(LocalPlayer) then
				self.joinLeaveButton:SetToolTip("You are not on the whitelist")
			elseif activity:IsPlayerBanned(LocalPlayer) then
				self.joinLeaveButton:SetToolTip("You are banned from this ativity")
			elseif GroupActivitiesClient:GetJoinedActivity() ~= nil then
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
		if GroupActivitiesClient:GetJoinedActivity() ~= nil and GroupActivitiesClient:GetJoinedActivity().leader == LocalPlayer then
			self.editor:SetActivity(GroupActivitiesClient:GetJoinedActivity())
		end
	end
end

function ActivityBrowser:OnTeleportButtonClick()
	GroupActivitiesClient:TeleportToLeader()
	self:SetActive(false)
end

function ActivityBrowser:OnJoinLeaveButtonClicked()
	if GroupActivitiesClient:GetJoinedActivity() == self:GetSelectedActivity() then
		GroupActivitiesClient:LeaveActivity(self:GetSelectedActivity())
	else
		GroupActivitiesClient:JoinActivity(self:GetSelectedActivity())
	end
end

function ActivityBrowser:GetSelectedActivity()
	return self.activities[tonumber(self.activityList:GetSelectedRow():GetCellText(0))]
end