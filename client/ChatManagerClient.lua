class("ChatManagerClient")

function ChatManagerClient:__init()
	self.ignoreNextMessage = false

	Network:Subscribe("ChatIgnore", self, self.OnChatIgnore)
	Events:Subscribe("PlayerChat", self, self.OnPlayerChat)
end

function ChatManagerClient:OnChatIgnore()
	self.ignoreNextMessage = true
end

function ChatManagerClient:OnPlayerChat(args)
	if not self.ignoreNextMessage then
		return true
	else
		return false
	end

	self.ignoreNextMessage = false
end

ChatManagerClient = ChatManagerClient()