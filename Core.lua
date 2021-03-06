--The Hankinator's UI library

import "Addons/THUI/QTree.lua"

if THUI~=nil then return end

THUI = {}

--I hate this function but I can't think of a way around it right now...
function THUI:Initialize()
	self.groups = {}
	self.active_groups = {}
	self.mouse_over_element = false

	self.default_fg_color = Vec4(1.0, 1.0, 1.0, 1.0)
	self.default_bg_color = Vec4(0.0, 0.0, 0.0, 1.0)
	self.default_inactive_color = Vec4(0.2, 0.2, 0.2, 1.0)
	self.default_hover_color = Vec4(1.0, 0.0, 0.0, 1.0)
	self.default_mouse_down_color = Vec4(1.0, 1.0, 0.0, 1.0)

	if self.FontCache == nil then
		self.FontCache = {}
	else
		--do I want to release all the fonts?
	end

	--scale modes
	self.ABSOLUTE = 0
	self.AUTOSCALE = 1
	self.ANCHOR = 2

	--x
	self.LEFT = 0
	self.CENTER = 1
	self.RIGHT = 2
	--y
	self.MIDDLE = 3
	self.TOP = 4
	self.BOTTOM = 5
end

function THUI:CreateGroup(name, data, mode, anchorx, anchory, width, height)

	local ctx = Context:GetCurrent()

	local group = {
		name=name,
		data=data,
		mode=mode,
		active=false,
		showmouse=true,
		anchorx=anchorx,
		anchory=anchory,
		width=width,
		height=height,
		qtree=qtree_create(4, 4, 0, 0, ctx:GetWidth(), ctx:GetHeight()),
		widgets={},
		Add=THUI.GroupAdd
	}
	
	table.insert(THUI.groups, group)

	return group
end

function THUI:_Show(group)
	local wnd = Window:GetCurrent()
	wnd:FlushKeys()
	wnd:FlushMouse()
	
	if group.showmouse == true then
		wnd:ShowMouse()
	end

	if not group.active then
		table.insert(self.active_groups, group)
		group.active = true
	end
end

function THUI:Show(name)
	if type(name) == "string" then
		for i=1, #self.groups do
			if self.groups[i].name == name then
				self:_Show(self.groups[i])
			end
		end
	else
		self:_Show(name)
	end
end

function THUI:_Hide(group)
	local showmouse = false
	
	local wnd = Window:GetCurrent()
	wnd:FlushKeys()
	wnd:FlushMouse()
	
	if group.active then
		for i=#self.active_groups, 1, -1 do
			if self.active_groups[i] == group then
				table.remove(self.active_groups, i)
			elseif self.active_groups[i].showmouse then
				showmouse = true
			end
		end
		group.active = false
	end

	if not showmouse then
		wnd:HideMouse()
	end
end

function THUI:Hide(name)
	if type(name) == "string" then
		for i=1, #self.groups do
			if self.groups[i].name == name then
				self:_Hide(self.groups[i])
			end
		end
	else
		self:_Hide(name)
	end
end

function THUI:Update()
	local ctx = Context:GetCurrent()
	local wnd = Window:GetCurrent()

	local mouse_pos = wnd:GetMousePosition()
	self.mouse_over_element = false
	local clicked = false

	if self.mouse_down and not wnd:MouseDown(1) then
		self.mouse_down = false
		clicked = true
	elseif wnd:MouseDown(1) then
		self.mouse_down = true
	end
	
--Make a copy of self.active_groups in case changes are made to self.active_groups
--during the update, iterate over the copy
	local active_groups = {}

	for i=1, #self.active_groups do
		table.insert(active_groups, self.active_groups[i])
	end

	for i=1, #active_groups do
		local active_group = active_groups[i]
		
		if active_group.active then
			if active_group.update ~= nil then
				self:DoCallback(active_group.update, active_group)
			end

			--draw
			ctx:SetBlendMode(Blend.Alpha)
			
			for k,v in pairs(active_group.widgets) do
				
				if v.visible then
					v:draw(ctx)
				end
			end

			--ctx:SetColor(0, 1, 0, 1)
			--_qtree_draw(active_group.qtree)
			
			--do events
			local result = qtree_lookup(active_group.qtree, mouse_pos.x, mouse_pos.y)
			
			if result ~= nil then
				local k,v
				for k,v in pairs(result) do
					if v.visible and v.active then
						if mouse_pos.x > v.x and mouse_pos.x < v.x + v.width and
							mouse_pos.y > v.y and mouse_pos.y < v.y + v.height then
							v.hover = true
							v.mouse_down = self.mouse_down
							self.mouse_over_element = true
							
							if clicked then
								if v.click ~=nil then
									self:DoCallback(v.click, v)
								end
							end
						end
					end
				end
			end

		end
	end
end

function THUI:DoCallback(callback, widget)
	if callback[2] ~= nil then
		callback[1](callback[2], widget, callback[3])
	elseif callback[2] ~= nil then
		callback[1](arg, callback[3])
	end
end

function THUI:_ScaleFont(fontpath, fontheight, ratio_w, ratio_h)
	local ctx = Context:GetCurrent()

	local font = self:GetFont(fontpath, fontheight)
	local fontwidth = font:GetTextWidth("0")

	local target_w = fontwidth * ratio_w
	local target_h = fontheight * ratio_h

	font = self:GetFont(fontpath, target_h)
	textwidth = font:GetTextWidth("0")

	if textwidth > target_w then
		scaled_size = target_h * (target_w / textwidth)
	else
		scaled_size = target_h
	end

	return scaled_size
end

function THUI:GetFont(path, size)
	local font = self.FontCache[path]

	if font == nil then
		font = {}
		self.FontCache[path] = font
	end

	local CachedFont = font[size]

	if CachedFont == nil then
		CachedFont = Font:Load(path, size)
		font[size] = CachedFont
	end

	return CachedFont
end

function THUI:_CalcJustifyX(x, width, justify)
	if justify == THUI.CENTER then
		x = x - width/2
	elseif justify == THUI.RIGHT then
		x = x - width
	end

	return x
end

function THUI:_CalcJustifyY(y, height, justify)
	if justify == THUI.MIDDLE then
		y = y - height/2
	elseif justify == THUI.BOTTOM then
		y = y - height
	end

	return y
end

function THUI:Callback(func, tbl, arg)
	return {func, tbl, arg}
end

function THUI:MouseOverUI()
	return self.mouse_over_element
end

function THUI:DrawText(ctx, text, x, y, justify_x, justify_y)
	x = self:_CalcJustifyX(x, ctx:GetFont():GetTextWidth(text), justify_x)
	y = self:_CalcJustifyY(y, ctx:GetFont():GetHeight(), justify_y)
	ctx:DrawText(text, x, y)
end

function THUI:CreateWidget(x, y, width, height, justify_x, justify_y)
	local w = {
		x = THUI:_CalcJustifyX(x, width, justify_x),
		y = THUI:_CalcJustifyY(y, height, justify_y),
		width = width,
		height = height,
		fg_color = THUI.default_fg_color,
		bg_color = THUI.default_bg_color,
		inactive_color = THUI.default_inactive_color,
		visible = true,
		font_path = "Fonts/arial.ttf",
		font_size = 10
	}

	return w
end

function THUI:GroupAdd(widget)
	if widget.widgets ~= nil then
		for k,v in pairs(widget.widgets) do
			self:Add(v)
		end
	else
		local ctx = Context:GetCurrent()

		if self.mode == THUI.AUTOSCALE then
			local ratio_w = ctx:GetWidth() / self.width
			local ratio_h = ctx:GetHeight() / self.height

			widget.x = widget.x * ratio_w
			widget.y = widget.y * ratio_h

			if widget.maintain_aspect_ratio then
				local aspect_ratio = math.min(ratio_w, ratio_h)
				local total_width = widget.width * ratio_w
				local total_height = widget.width * ratio_h
				
				widget.width = widget.width * aspect_ratio
				widget.height = widget.height * aspect_ratio
				widget.x = widget.x + (total_width - widget.width)/2
				widget.y = widget.y + (total_height - widget.height)/2
			else
				widget.width = widget.width * ratio_w
				widget.height = widget.height * ratio_h
			end

			local ScaledFontSize = THUI:_ScaleFont(widget.font_path, widget.font_size, ratio_w, ratio_h)
			widget.font = THUI:GetFont(widget.font_path, ScaledFontSize)
			
		elseif self.mode == THUI.ANCHOR then
			if self.anchorx == THUI.RIGHT then
				widget.x = ctx:GetWidth() - self.width + widget.x
			elseif self.anchorx == THUI.CENTER then
				widget.x = ctx:GetWidth()/2 - self.width/2 + widget.x
			end

			if self.anchory == THUI.BOTTOM then
				widget.y = ctx:GetHeight() - self.height + widget.y
			elseif self.anchory == THUI.MIDDLE then
				widget.y = ctx:GetHeight()/2 - self.height/2 + widget.y
			end

			widget.font = THUI:GetFont(widget.font_path, widget.font_size)
		else
			widget.font = THUI:GetFont(widget.font_path, widget.font_size)
		end

		if widget.interactive then
			qtree_insert(self.qtree, widget)
		end

		table.insert(self.widgets, widget)
	end
end

--I can't think of a better spot for this function right now, bleh.
function THUI:PauseGame(pause)
	if pause then
		paused = true
		Time:Pause()
	else
		paused = false
		Time:Resume()
	end
end

function THUI:GamePaused()
	return paused
end