class("GroupActivitiesClient")

function GroupActivitiesClient:__init()
	self.activities = {}
	self.browser = nil

	Network:Subscribe("ActivityList", self, self.OnActivityListReceived)
	Events:Subscribe("KeyUp", self, self.OnKey)
	Events:Subscribe("LocalPlayerChat", self, self.OnChat)
end

function GroupActivitiesClient:OnActivityListReceived(activityList)
	self.activities = {}

	for id, activityTable in pairs(activityList) do
		self.activities[id] = Activity.FromTable(activityTable)
	end

	if self.browser ~= nil then self.browser:SetActivities(self.activities) end
end

function GroupActivitiesClient:OnChat(args)
	if args.text == "/activities" then
		self:ShowBrowser()

		return false
	end
end

function GroupActivitiesClient:OnKey(args)
	if args.key == string.byte('G') then
		self:ShowBrowser()
	end
end

function GroupActivitiesClient:GetJoinedActivity()
	for id, activity in pairs(self.activities) do
		if activity:IsPlayerInActivity(LocalPlayer) then
			return activity
		end
	end
end

function GroupActivitiesClient:ShowBrowser()
	if self.browser == nil then
		self.browser = ActivityBrowser()
		self.browser:SetActive(false)
	end
	self.browser:SetActive(not self.browser.active)
	self.browser:SetActivities(self.activities)
end

function GroupActivitiesClient:JoinActivity(activity)
	Network:Send("ActivityJoined", {activityId = activity.id, player = LocalPlayer})
end

function GroupActivitiesClient:LeaveActivity(activity)
	Network:Send("ActivityLeft", {activityId = activity.id, player = LocalPlayer})
end

function GroupActivitiesClient:PromotePlayer(activity, player)
	Network:Send("PlayerPromoted", {activityId = activity.id, player = player})
end

function GroupActivitiesClient:SaveActivity(activity)
	Network:Send("ActivitySaved", activity:ToTable())
end

function GroupActivitiesClient:DeleteActivity(activity)
	Network:Send("ActivityDeleted", {activityId = activity.id})
end

GroupActivitiesClient = GroupActivitiesClient()