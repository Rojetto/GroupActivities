class("ActivityBrowser")

function ActivityBrowser:__init()
	self.active = true

	self.window = Window.Create()
	self.window:SetTitle("Group Activities")
	self.window:SetSizeRel(Vector2(0.5, 0.5))
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
	self.window:Subscribe("WindowClosed", self, self.OnWindowClosed)

	Events:Subscribe("LocalPlayerInput", self, self.OnLocalPlayerInput)
end

function ActivityBrowser:OnWindowClosed()
	self.active = false
end

function ActivityBrowser:OnLocalPlayerInput()
	Mouse:SetVisible(self.active)
	return not self.active
end