class("ActiveWindow")

function ActiveWindow:__init()
	self.active = true

	self.window = Window.Create()
	self.window:Subscribe("WindowClosed", self, self.Close)

	self.inputEvent = Events:Subscribe("LocalPlayerInput", self, self.OnLocalPlayerInput)
end

function ActiveWindow:OnLocalPlayerInput()
	Mouse:SetVisible(self.active)
	return not self.active
end

function ActiveWindow:Close()
	if self.active then
		self.active = false
		self.window:Hide()
		Events:Unsubscribe(self.inputEvent)
	end
end