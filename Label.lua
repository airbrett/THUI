--The Hankinator's UI library

import "Addons/THUI/THUI.lua"

if THUI.Label ~= nil then
	return
end

THUI.Label = {}


function THUI.Label:Create(x, y, width, height, text, justify_x, justify_y)
	local label = THUI:CreateWidget(x, y, width, height, justify_x, justify_y)
	
	label.text = text
	label.draw = self.Draw;
	label.text_justify_x = justify_x
	label.text_justify_y = justify_y
	label.bg_color = nil
	
	return label
end

function THUI.Label:Draw(ctx)
	if self.img ~= nil then
		ctx:DrawImage(self.img, self.x, self.y, self.width, self.height)
	elseif self.bg_color ~= nil then
		ctx:SetColor(self.bg_color)
		ctx:DrawRect(self.x, self.y, self.width, self.height, 0)
	end

	if self.text ~= nil then
		ctx:SetFont(self.font)
		ctx:SetColor(self.fg_color)

		local reference_x
		local reference_y

		if self.text_justify_x == THUI.LEFT then
			reference_x = self.x
		elseif self.text_justify_x == THUI.CENTER then
			reference_x = self.x + self.width / 2
		else--if self.text_justify_x == THUI.RIGHT then
			reference_x = self.x + self.width
		end

		if self.text_justify_y == THUI.TOP then
			reference_y = self.y
		elseif self.text_justify_y == THUI.MIDDLE then
			reference_y = self.y + self.height / 2
		else--if self.text_justify_y == THUI.BOTTOM then
			reference_y = self.y + self.height
		end
		

		local x = THUI:_CalcJustifyX(reference_x, self.font:GetTextWidth(self.text), self.text_justify_x)
		local y = THUI:_CalcJustifyY(reference_y, self.font:GetHeight(), self.text_justify_y)

		ctx:DrawText(self.text, x, y)
	end
end