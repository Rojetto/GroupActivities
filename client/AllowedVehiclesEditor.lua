class("AllowedVehiclesEditor")(ActiveWindow)

function AllowedVehiclesEditor:__init(editable, callbackObject, callbackFunction)
	ActiveWindow.__init(self)

	self.editable = editable
	self.callbackObject = callbackObject
	self.callbackFunction = callbackFunction

	self.allowedVehicles = {}
	self.checkBoxes = {}
	self.checkAllBoxes = {}

	self.window:SetSize(Vector2(500, 500))
	self.window:SetPositionRel(Vector2(0.5, 0.5) - self.window:GetSizeRel() / 2)
	self.window:SetTitle(editable and "Edit allowed vehicles" or "Allowed vehicles")

	self.vehicleList = CollapsibleList.Create(self.window)
	self.vehicleList:SetDock(GwenPosition.Fill)

	self.saveButton = Button.Create(self.window)
	self.saveButton:SetDock(GwenPosition.Bottom)
	self.saveButton:SetHeight(25)
	self.saveButton:SetPadding(Vector2(0, 5), Vector2(0, 0))
	self.saveButton:SetText("Save")
	self.saveButton:Subscribe("Press", self, self.OnSaveButtonClick)

	self:CreateCategories()
	self:FillList()

	local allVehiclesAllowed = {}
	for id = 1, 92, 1 do
		allVehiclesAllowed[id] = true
	end
	self:SetAllowedVehicles(allVehiclesAllowed)
end

function AllowedVehiclesEditor:SetAllowedVehicles(allowedVehicles)
	self.allowedVehicles = allowedVehicles

	for categoryName, _ in pairs(self.categories) do
		self.checkAllBoxes[categoryName]:SetDataBool("SilentCheck", true)
		self.checkAllBoxes[categoryName]:SetChecked(self:GetCheckedAllChecked(categoryName))
		self.checkAllBoxes[categoryName]:SetDataBool("SilentCheck", false)
	end

	for id, allowed in pairs(self.allowedVehicles) do
		if self.checkBoxes[id] ~= nil then
			self.checkBoxes[id]:SetChecked(allowed)
		end
	end
end

function AllowedVehiclesEditor:CreateCategories()
	self.categories = {}
	self.categories.Bike = {9, 22, 47, 83, 32, 90, 61, 89, 43, 74, 21, 36, 11}
	self.categories.Car = {44, 29, 15, 70, 55, 13, 54, 8}
	self.categories.Sportscar = {78, 2, 91, 35}
	self.categories.Jeep = {48, 87, 52, 10, 46, 72, 84, 77}
	self.categories.Pickup = {60, 26, 73, 23, 63, 68, 33, 86, 7}
	self.categories.Bus = {66, 12}
	self.categories.Truck = {42, 49, 71, 41, 4, 79}
	self.categories.Heavy = {40, 31, 76, 18, 56}
	self.categories.Tractor = {1}
	self.categories.Heli = {3, 14, 67, 57, 64, 65, 62}
	self.categories.Plane = {59, 81, 51, 30, 34, 39, 85}
	self.categories.Boat = {38, 5, 6, 19, 45, 16, 25, 28, 50, 80, 27, 88, 69}
end

function AllowedVehiclesEditor:FillList()
	for name, ids in pairs(self.categories) do
		local category = self.vehicleList:Add(name)
		local allButton = category:Add("All")
		allButton:SetHeight(20)
		self.checkAllBoxes[name] = CheckBox.Create(allButton)
		self.checkAllBoxes[name]:SetDock(GwenPosition.Right)
		self.checkAllBoxes[name]:SetChecked(true)
		self.checkAllBoxes[name]:SetEnabled(self.editable)
		self.checkAllBoxes[name]:SetDataBool("SilentCheck", false)
		self.checkAllBoxes[name]:Subscribe("CheckChanged", self, self.OnCheckAllBoxChanged)

		for _, id in pairs(ids) do
			local button = category:Add(id .. " " .. Vehicle.GetNameByModelId(id))
			button:SetHeight(20)
			self.checkBoxes[id] = CheckBox.Create(button)
			self.checkBoxes[id]:SetDock(GwenPosition.Right)
			self.checkBoxes[id]:SetEnabled(self.editable)
			self.checkBoxes[id]:SetDataBool("SilentCheck", false)
			self.checkBoxes[id]:Subscribe("CheckChanged", self, self.OnCheckBoxChanged)
		end
	end
end

function AllowedVehiclesEditor:GetCheckedAllChecked(categoryName)
	for _, id in pairs(self.categories[categoryName]) do
		if not self.allowedVehicles[id] then
			return false
		end
	end

	return true
end

function AllowedVehiclesEditor:GetCategory(vehicleId)
	for categoryName, ids in pairs(self.categories) do
		for _, id in pairs(ids) do
			if id == vehicleId then return categoryName end
		end
	end
end

function AllowedVehiclesEditor:OnCheckAllBoxChanged(box)
	if not box:GetDataBool("SilentCheck") then
		for categoryName, checkBox in pairs(self.checkAllBoxes) do
			if checkBox == box then
				for _, id in pairs(self.categories[categoryName]) do
					self.checkBoxes[id]:SetDataBool("SilentCheck", true)
					self.checkBoxes[id]:SetChecked(box:GetChecked())
					self.checkBoxes[id]:SetDataBool("SilentCheck", false)
					self.allowedVehicles[id] = box:GetChecked()
				end
			end
		end
	end
end

function AllowedVehiclesEditor:OnCheckBoxChanged(box)
	if not box:GetDataBool("SilentCheck") then
		for id, checkBox in pairs(self.checkBoxes) do
			if checkBox == box then
				self.allowedVehicles[id] = box:GetChecked()
				local category = self:GetCategory(id)
				self.checkAllBoxes[category]:SetDataBool("SilentCheck", true)
				self.checkAllBoxes[category]:SetChecked(self:GetCheckedAllChecked(category))
				self.checkAllBoxes[category]:SetDataBool("SilentCheck", false)
			end
		end
	end
end

function AllowedVehiclesEditor:OnSaveButtonClick()
	self.callbackFunction(self.callbackObject, self.allowedVehicles)

	self:Close()
end