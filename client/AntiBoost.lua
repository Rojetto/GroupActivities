class("AntiBoost")

function AntiBoost:__init()
	self.inVehicleTimer = Timer()
	Events:Subscribe("Render", self, self.OnRender)
	Events:Subscribe("LocalPlayerEnterVehicle", self, self.OnEnterVehicle)
end

function AntiBoost:OnRender()
	if GroupActivitiesClient:GetJoinedActivity(LocalPlayer) == nil then return end
	if GroupActivitiesClient:GetJoinedActivity(LocalPlayer).boost then return end
	if not LocalPlayer:InVehicle() then return end
	if not LocalPlayer:GetState() == PlayerState.InVehicle then return end
	if self.inVehicleTimer:GetSeconds() < 1 then return end
	local v = LocalPlayer:GetVehicle()
	if self.lastVelocity == nil then self.lastVelocity = v:GetLinearVelocity() end

	local newVelocity = v:GetLinearVelocity()
	local forward = v:GetAngle() * Vector3(0, 0, -1)

	if newVelocity:Length() > self.lastVelocity:Length() and (newVelocity - self.lastVelocity):Length() > (forward * 5):Length() then
		GroupActivitiesClient:SetVehicleVelocity(self.lastVelocity)
	else
		self.lastVelocity = newVelocity
	end
end

function AntiBoost:OnEnterVehicle()
	self.inVehicleTimer:Restart()
end