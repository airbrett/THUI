--The Hankinator's UI library

import "Addons/THUI/THUI.lua"

if THUI.Button ~= nil then
	return
end

THUI.Button = {}


function THUI.Button:Create(x, y, width, height, text, justify_x, justify_y)
	local button = THUI:CreateWidget(x, y, width, height, justify_x, justify_y)
	
	button.text = text
	button.active = true;
	button.interactive = true
	button.hover_color = THUI.default_hover_color
	button.mouse_down_color = THUI.default_mouse_down_color
	button.draw = self.Draw;
	
	return button
end


function THUI.Button:Draw(ctx)
	local img
	local fg

	if not self.active then
		if self.img_inactive ~= nil then
			img = self.img_inactive
		end
		fg = self.inactive_color
	elseif self.mouse_down then
		if self.img_mouse_down ~= nil then
			img = self.img_mouse_down
		end
		fg = self.mouse_down_color
		self.mouse_down = false
	elseif self.hover == true then
		if self.img_hover ~= nil then
			img = self.img_hover
		end
		fg = self.hover_color
		self.hover = false
	else
		if self.img_mouseup ~= nil then
			img = self.img_mouseup
		end
		fg = self.fg_color
	end

	if img ~= nil then
		ctx:SetColor(1.0, 1.0, 1.0, 1.0)
		ctx:DrawImage(img, self.x, self.y, self.width, self.height)
	else
		--bg
		ctx:SetColor(self.bg_color)
		ctx:DrawRect(self.x, self.y, self.width, self.height, 0)
		--fg
		ctx:SetColor(fg)
		ctx:DrawRect(self.x, self.y, self.width, self.height, 1)
	end

	if self.text ~= nil then
		ctx:SetFont(self.font)
		ctx:SetColor(fg)
		THUI:DrawText(ctx, self.text, self.x + self.width/2, self.y + self.height/2, THUI.CENTER, THUI.MIDDLE)
	end
end