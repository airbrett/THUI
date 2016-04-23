--The Hankinator's UI library

import "Addons/THUI/THUI.lua"

if THUI.Label ~= nil then
	return
end

THUI.Label = {}


function THUI.Label:Create(x, y, width, height, text, justify_x, justify_y)
	local label = THUI:CreateWidget(x, y, width, height, justify_x, justify_y)
	
	label.text = text
	label.font = THUI.default_font
	label.draw = self.Draw;
	label.x_justify = justify_x
	label.y_justify = justify_y
	
	return label
end

function THUI.Label:Draw(ctx)
	ctx:SetColor(self.fg_color)
	ctx:SetFont(self.font)

	if self.img ~= nil then
		ctx:DrawImage(self.img, self.x, self.y, self.width, self.height)
	end

	if self.text ~= nil then
		local x = THUI:_CalcJustifyX(self.x, self.font:GetTextWidth(self.text), self.x_justify)
		local y = THUI:_CalcJustifyY(self.y, self.font:GetHeight(), self.y_justify)
		ctx:DrawText(self.text, x, y)
	end
end