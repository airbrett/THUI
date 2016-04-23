--The Hankinator's UI library

import "Addons/THUI/THUI.lua"

if THUI.CheckBox ~= nil then
	return
end

THUI.CheckBox = {}

function THUI.CheckBox:Create(x, y, width, height, justify_x, justify_y)
	local checkbox = THUI:CreateWidget(x, y, width, height, justify_x, justify_y)
	
	checkbox.active = true;
	checkbox.interactive = true
	checkbox.hover_color = THUI.default_hover_color
	checkbox.mouse_down_color = THUI.default_mouse_down_color

	checkbox.checked = false
	checkbox.click = THUI:Callback(self.Clicked, checkbox)
	checkbox.draw = self.Draw
	return checkbox;
end

function THUI.CheckBox:Clicked()
	self.checked = not self.checked
end

function THUI.CheckBox:Draw(ctx)
	local img
	local fg

	if self.checked then
		if not self.active then
			if self.img_checked_inactive ~= nil then
				img = self.img_checked_inactive
			end
			fg = self.inactive_color
		elseif self.mouse_down then
			if self.img_checked_mouse_down ~= nil then
				img = self.img_checked_mouse_down
			end
			fg = self.mouse_down_color
			self.mouse_down = false
		elseif self.hover == true then
			if self.img_checked_hover ~= nil then
				img = self.img_checked_hover
			end
			fg = self.hover_color
			self.hover = false
		else
			if self.img_checked_mouseup ~= nil then
				img = self.img_checked_mouseup
			end
			fg = self.fg_color
		end
	else
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

		if self.checked then
			ctx:DrawLine(self.x, self.y, self.x + self.width, self.y + self.height)
			ctx:DrawLine(self.x, self.y + self.height, self.x + self.width, self.y)
		end
	end
end