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
		if activity:IsPlayerInActivity(LocalPlayer) then
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

function PromotePlayer(activity, player)
	Network:Send("PlayerPromoted", {activityId = activity.id, player = player})
end

function SaveActivity(activity)
	Network:Send("ActivitySaved", activity:ToTable())
end

function DeleteActivity(activity)
	Network:Send("ActivityDeleted", {activityId = activity.id})
end