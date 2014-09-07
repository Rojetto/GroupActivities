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

	self.bottomBase = BaseWindow.Create(self.window)
	self.bottomBase:SetDock(GwenPosition.Bottom)
	self.bottomBase:SetHeight(25)
	self.bottomBase:SetWidthAutoRel(1.0)

	self.activityList = SortedList.Create(self.browserBase)
	self.activityList:SetDock(GwenPosition.Left)
	self.activityList:SetWidthAutoRel(0.7)
	self.activityList:AddColumn("Id")
	self.activityList:AddColumn("Name")
	self.activityList:AddColumn("Leader")
	self.activityList:AddColumn("Access")
	self.activityList:AddColumn("Players")
	self.activityList:Subscribe("RowSelected", self, self.OnRowSelected)

	self.details = BaseWindow.Create(self.browserBase)
	self.details:SetWidthAutoRel(0.3)
	self.details:SetDock(GwenPosition.Right)

	self.descriptionScrollControl = ScrollControl.Create(self.details)
	self.descriptionScrollControl:SetWidthAutoRel(1.0)
	self.descriptionScrollControl:SetHeight(100)

	self.descriptionBox = TextBoxMultiline.Create(self.descriptionScrollControl)
	self.descriptionBox:SetEnabled(false)
	self.descriptionBox:SetHeight(100)
	self.descriptionBox:SetWidthAutoRel(0.95)

	self.joinLeaveButton = Button.Create(self.details)
	self.joinLeaveButton:SetText("Join")
	self.joinLeaveButton:SetToolTip("You need to select an activity")
	self.joinLeaveButton:SetEnabled(false)
	self.joinLeaveButton:SetDock(GwenPosition.Bottom)
	self.joinLeaveButton:SetHeight(25)
	self.joinLeaveButton:Subscribe("Press", self, self.OnJoinLeaveButtonClicked)

	self.createEditButton = Button.Create(self.bottomBase)
	self.createEditButton:SetSizeAutoRel(Vector2(1.0, 1.0))
	self.createEditButton:SetText("Create activity")
	self.createEditButton:Subscribe("Press", self, self.OnCreateEditButtonClicked)

	self.activities = {}

	Events:Subscribe("LocalPlayerInput", self, self.OnLocalPlayerInput)
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

		if id == GetJoinedActivity().id then
			row:SetTextColor(Color(0, 255, 0))
			selectedRow = row
		end
	end

	if selectedRow ~= nil then
		self.activityList:SetSelectRow(selectedRow)
	else
		self:ShowDetails(nil)
	end

	if GetJoinedActivity() == nil then
		self.createEditButton:SetText("Create activity")
		self.createEditButton:SetToolTip("Create a new activity")
	else
		if GetJoinedActivity().leader == LocalPlayer then
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
	if active then self.window:Show() else self.window:Hide() end
end

function ActivityBrowser:OnRowSelected()
	local activity = self:GetSelectedActivity()
	self:ShowDetails(activity)
end

function ActivityBrowser:ShowDetails(activity)
	self.descriptionBox:SetText("No description")
	self.descriptionBox:SetHeight(100)

	self.joinLeaveButton:SetText("Join")
	self.joinLeaveButton:SetToolTip("You need to select an activity")
	self.joinLeaveButton:SetEnabled(false)

	if activity ~= nil then
		if activity.description ~= "" then
			self.descriptionBox:SetText(activity.description)
			self.descriptionBox:SizeToContents()
			if self.descriptionBox:GetHeight() < 100 then
				self.descriptionBox:SetHeight(100)
			end
			self.descriptionBox:SetWidthAutoRel(0.95)
		end

		if GetJoinedActivity() == nil or GetJoinedActivity().id ~= activity.id then
			if activity.access == Access.Whitelist and not activity:IsPlayerWhitelisted(LocalPlayer) then
				self.joinLeaveButton:SetToolTip("You are not on the whitelist")
			elseif activity:IsPlayerBanned(LocalPlayer) then
				self.joinLeaveButton:SetToolTip("You are banned from this ativity")
			elseif GetJoinedActivity() ~= nil then
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
	local editor = ActivityEditor(OnActivityCreated)
	if GetJoinedActivity() ~= nil and GetJoinedActivity().leader == LocalPlayer then
		editor:SetActivity(GetJoinedActivity())
	end
end

function ActivityBrowser:OnJoinLeaveButtonClicked()
	if GetJoinedActivity() == self:GetSelectedActivity() then
		LeaveActivity(self:GetSelectedActivity())
	else
		JoinActivity(self:GetSelectedActivity())
	end
end

function ActivityBrowser:GetSelectedActivity()
	return self.activities[tonumber(self.activityList:GetSelectedRow():GetCellText(0))]
end