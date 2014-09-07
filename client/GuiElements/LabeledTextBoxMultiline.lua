class("LabeledTextBoxMultiline")(TextBoxMultiline)

function LabeledTextBoxMultiline.Create(baseWindow)
	local self = TextBoxMultiline.Create(baseWindow)
	self.labelText = ""
	self.modified = false
	self.GetText = LabeledTextBoxMultiline.GetText
	self.SetLabel = LabeledTextBoxMultiline.SetLabel
	self.GetLabel = LabeledTextBoxMultiline.GetLabel
	self.IsModified = LabeledTextBoxMultiline.IsModified
	self.OnFocus = LabeledTextBoxMultiline.OnFocus
	self.OnBlur = LabeledTextBoxMultiline.OnBlur
	self.OnTextChanged = LabeledTextBoxMultiline.OnTextChanged

	self:Subscribe("Focus", self, self.OnFocus)
	self:Subscribe("Blur", self, self.OnBlur)
	self:Subscribe("TextChanged", self, self.OnTextChanged)

	self:SetText(self.labelText)

	return self
end

function LabeledTextBoxMultiline:GetText()
	if self.modified then
		return TextBoxMultiline.GetText(self)
	else
		return ""
	end
end

function LabeledTextBoxMultiline:SetLabel(labelText)
	self.labelText = labelText
	self:SetText(self.labelText)
end

function LabeledTextBoxMultiline:GetLabel()
	return self.labelText
end

function LabeledTextBoxMultiline:IsModified()
	return self.modified
end

function LabeledTextBoxMultiline:OnFocus()
	if not self.modified then
		self:SetText("")
	end
end

function LabeledTextBoxMultiline:OnBlur()
	if not self.modified then
		self:SetText(self.labelText)
	end
end

function LabeledTextBoxMultiline:OnTextChanged()
	if TextBoxMultiline.GetText(self) ~= "" and TextBoxMultiline.GetText(self) ~= self.labelText then
		self.modified = true
	end
end