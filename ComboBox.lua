--The Hankinator's UI library

import "Addons/THUI/THUI.lua"

if THUI.ComboBox ~= nil then
	return
end

THUI.ComboBox = {}

function THUI.ComboBox:Create(x, y, width, height, values, selected, justify_x, justify_y)
	local combo = {}
	combo.x = THUI:_CalcJustifyX(x, width, justify_x)
	combo.y = THUI:_CalcJustifyY(y, height, justify_y)
	combo.width = width
	combo.height = height
	combo.ComboBoxSelectValue = THUI.ComboBox.ComboBoxSelectValue

	combo.widgets = {}
	combo.values = values
	combo.selected = selected
	combo.label = THUI.Label:Create(combo.x + width/2, combo.y + height/2, 0, 0, combo.values[combo.selected], THUI.CENTER, THUI.MIDDLE)
	
	--Left button
	combo.left_button = THUI.Button:Create(combo.x, combo.y, height, height, "-")
	combo.left_button.click = THUI:Callback(self.Decrement, combo)

	--Right button
	combo.right_button = THUI.Button:Create(combo.x + width - height, combo.y, height, height, "+")
	combo.right_button.click = THUI:Callback(self.Increment, combo)

	table.insert(combo.widgets, combo.label)
	table.insert(combo.widgets, combo.left_button)
	table.insert(combo.widgets, combo.right_button)
	
	return combo
end

function THUI.ComboBox:Decrement()
	self:ComboBoxSelectValue(-1)
end

function THUI.ComboBox:Increment()
	self:ComboBoxSelectValue(1)
end

function THUI.ComboBox:ComboBoxSelectValue(delta)
	if self.values[self.selected + delta] ~= nil then
		self.selected = self.selected + delta
		self.label.text = self.values[self.selected]
	end
end