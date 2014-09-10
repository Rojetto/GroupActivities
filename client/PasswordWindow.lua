class("PasswordWindow")(ActiveWindow)

function PasswordWindow:__init(activity, callbackObject, callbackFunction)
	self.activity = activity
	self.callbackObject = callbackObject
	self.callbackFunction = callbackFunction

	self.window:SetTitle("Enter password")
	self.window:SetSize(Vector2(500, 200))
	self.window:DisableResizing()

	self.label = Label.Create(self.window)
	self.label:SetText("Enter password to join.")
	self.label:SizeToContents()

	self.passwordBox = PasswordTextBox.Create(self.window)
	self.passwordBox:SetPosition(Vector2(0, 30))
	self.passwordBox:SetHeight(25)
	self.passwordBox:SetWidthAutoRel(1.0)

	self.joinButton = Button.Create(self.window)
	self.joinButton:SetPosition(Vector2(0, 60))
	self.joinButton:SetHeight(25)
	self.joinButton:SetWidthAutoRel(1.0)
	self.joinButton:SetText("Join")
	self.joinButton:Subscribe("Press", self, self.OnJoinButtonClick)
end

function PasswordWindow:OnJoinButtonClick()
	if self.passwordBox:GetText() == self.activity.password then
		self.callbackFunction(self.callbackObject, self.activity)
	end
end