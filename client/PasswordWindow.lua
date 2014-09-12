class("PasswordWindow")(ActiveWindow)

function PasswordWindow:__init(activity, callbackObject, callbackFunction)
	ActiveWindow.__init(self)

	self.activity = activity
	self.callbackObject = callbackObject
	self.callbackFunction = callbackFunction

	self.window:SetTitle("Enter password")
	self.window:SetSize(Vector2(200, 120))
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)

	self.label = Label.Create(self.window)
	self.label:SetText("Enter password to join.")
	self.label:SetWidthAutoRel(1.0)
	self.label:SetHeight(25)
	self.label:SetAlignment(GwenPosition.CenterV)

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
		self:Close()
	end
end