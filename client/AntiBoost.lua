class("AntiBoost")

function AntiBoost:__init()
	self.timer = Timer()
	self.inVehicleTimer = Timer()
	Events:Subscribe("Render", self, self.OnRender)
	Events:Subscribe("LocalPlayerEnterVehicle", self, self.OnEnterVehicle)
end

function AntiBoost:OnRender()
	if GroupActivitiesClient:GetJoinedActivity() == nil then return end
	if GroupActivitiesClient:GetJoinedActivity().boost then return end
	if not LocalPlayer:InVehicle() then return end
	if not LocalPlayer:GetState() == PlayerState.InVehicle then return end
	if self.inVehicleTimer:GetSeconds() < 1 then return end
	local v = LocalPlayer:GetVehicle()
	if self.lastVelocity == nil then self.lastVelocity = v:GetLinearVelocity() end

	local newVelocity = v:GetLinearVelocity()
	local forward = v:GetAngle() * Vector3(0, 0, -1)

	if (newVelocity - self.lastVelocity):Length() > (forward * 5):Length() then
		GroupActivitiesClient:SetVehicleVelocity(self.lastVelocity)
		self.timer:Restart()
	else
		self.lastVelocity = newVelocity
	end

	if self.timer:GetSeconds() < 5 then
		local text = "Boosting is not allowed in this activity"
		local textSize = Render:GetTextSize(text, 40)

		Render:DrawText((Render.Size / 2) - (textSize / 2) - Vector2(0, Render.Height / 3), text, Color(255, 0, 0), 40)
	end
end

function AntiBoost:OnEnterVehicle()
	self.inVehicleTimer:Restart()
end