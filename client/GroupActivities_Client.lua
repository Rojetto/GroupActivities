function OnActivityCreated(newActivity)
	Network:Send("ActivityCreated", newActivity:ToTable())
end

function OnChat(args)
	if args.text == "/activities" then
		ActivityBrowser()

		return false
	end
end
Events:Subscribe("LocalPlayerChat", OnChat)