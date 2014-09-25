class("ChatManagerClient")

function ChatManagerClient:__init()
	self.ignoreNextMessage = false
	self.nextMessage = ""

	Network:Subscribe("ChatIgnore", self, self.OnChatIgnore)
	Events:Subscribe("PlayerChat", self, self.OnPlayerChat)
end

function ChatManagerClient:OnChatIgnore(nextMessage)
	self.ignoreNextMessage = true
	self.nextMessage = nextMessage
end

function ChatManagerClient:OnPlayerChat(args)
	local show = true
	if self.ignoreNextMessage and args.text == self.nextMessage then
		show = false
	end

	self.ignoreNextMessage = false
	return show
end

ChatManagerClient = ChatManagerClient()