local activities = {}
local browser = nil

function OnActivityListReceived(activityList)
	activities = {}

	for id, activityTable in pairs(activityList) do
		activities[id] = Activity.FromTable(activityTable)
	end

	if browser ~= nil then browser:SetActivities(activities) end
end
Network:Subscribe("ActivityList", OnActivityListReceived)

function OnActivityCreated(newActivity)
	Network:Send("ActivityCreated", newActivity:ToTable())
end

function OnChat(args)
	if args.text == "/activities" then
		ShowBrowser()

		return false
	end
end
Events:Subscribe("LocalPlayerChat", OnChat)

function OnKey(args)
	if args.key == string.byte('G') then
		ShowBrowser()
	end
end
Events:Subscribe("KeyUp", OnKey)

function GetJoinedActivity()
	for id, activity in pairs(activities) do
		local isPlayerInActivity = activity:IsPlayerInActivity(LocalPlayer)
		if isPlayerInActivity then
			return activity
		end
	end
end

function ShowBrowser()
	if browser == nil then
		browser = ActivityBrowser()
		browser:SetActive(false)
	end
	browser:SetActive(not browser.active)
	browser:SetActivities(activities)
end

function JoinActivity(activity)
	Network:Send("ActivityJoined", {activityId = activity.id, player = LocalPlayer})
end

function LeaveActivity(activity)
	Network:Send("ActivityLeft", {activityId = activity.id, player = LocalPlayer})
end