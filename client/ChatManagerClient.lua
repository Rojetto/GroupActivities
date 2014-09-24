class("ChatManagerClient")

function ChatManagerClient:__init()
	self.ignoreNextMessage = false

	Network:Subscribe("ChatIgnore", self, self.OnChatIgnore)
	Events:Subscribe("PlayerChat", self, self.OnPlayerChat)
end

function ChatManagerClient:OnChatIgnore()
	self.ignoreNextMessage = true
	print("Ignore the next message")
end

function ChatManagerClient:OnPlayerChat(args)
	if not self.ignoreNextMessage then
		return true
	else
		self.ignoreNextMessage = false
		return false
	end
end

ChatManagerClient = ChatManagerClient()