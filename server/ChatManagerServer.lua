class("ChatManagerServer")

function ChatManagerServer:__init()
	Events:Subscribe("PlayerChat", self, self.OnPlayerChat)
end

function ChatManagerServer:OnPlayerChat(args)
	if args.text:sub(1, 1) ~= "/" then
		for receiver in Server:GetPlayers() do
			if not self:GetsMessageSent(args.player, receiver) then
				Network:Send(receiver, "ChatIgnore")
			end
			local senderActivity = GroupActivitiesServer:GetJoinedActivity(args.player)
			local receiverActivity = GroupActivitiesServer:GetJoinedActivity(receiver)

			if senderActivity ~= nil and receiverActivity ~= nil and senderActivity.id == receiverActivity.id and senderActivity.leaderId == args.player:GetId() then
				Network:Send(receiver, "ChatIgnore")
				Chat:Send(receiver, "[Leader] " .. args.player:GetName() .. ": " .. args.text, Color(153, 102, 204))
			end
		end
	end

	return true
end

function ChatManagerServer:GetsMessageSent(sender, receiver)
	local senderActivity = GroupActivitiesServer:GetJoinedActivity(sender)
	local receiverActivity = GroupActivitiesServer:GetJoinedActivity(receiver)

	if (senderActivity == nil) ~= (receiverActivity == nil) then
		return false
	end
	if (senderActivity == nil) and (receiverActivity == nil) then
		return true
	end
	if senderActivity.id == receiverActivity.id then
		return true
	else
		return false
	end
end

ChatManagerServer = ChatManagerServer()