class("LabeledTextBox")(TextBox)

function LabeledTextBox.Create(baseWindow)
	local self = TextBox.Create(baseWindow)
	self.labelText = ""
	self.modified = false
	self.GetText = LabeledTextBox.GetText
	self.SetLabel = LabeledTextBox.SetLabel
	self.GetLabel = LabeledTextBox.GetLabel
	self.IsModified = LabeledTextBox.IsModified
	self.OnFocus = LabeledTextBox.OnFocus
	self.OnBlur = LabeledTextBox.OnBlur
	self.OnTextChanged = LabeledTextBox.OnTextChanged

	self:Subscribe("Focus", self, self.OnFocus)
	self:Subscribe("Blur", self, self.OnBlur)
	self:Subscribe("TextChanged", self, self.OnTextChanged)

	self:SetText(self.labelText)

	return self
end

function LabeledTextBox:GetText()
	if self.modified then
		return TextBox.GetText(self)
	else
		return ""
	end
end

function LabeledTextBox:SetLabel(labelText)
	self.labelText = labelText
	self:SetText(self.labelText)
end

function LabeledTextBox:GetLabel()
	return self.labelText
end

function LabeledTextBox:IsModified()
	return self.modified
end

function LabeledTextBox:OnFocus()
	if not self.modified then
		self:SetText("")
	end
end

function LabeledTextBox:OnBlur()
	if not self.modified then
		self:SetText(self.labelText)
	end
end

function LabeledTextBox:OnTextChanged()
	if TextBox.GetText(self) ~= "" and TextBox.GetText(self) ~= self.labelText then
		self.modified = true
	end
end