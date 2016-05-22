--The Hankinator's UI library

import "Addons/THUI/QTree.lua"

if THUI~=nil then return end

THUI = {
	groups = {},
	active_groups = {},
	mouse_over_element = false,

	default_fg_color = Vec4(1.0, 1.0, 1.0, 1.0),
	default_bg_color = Vec4(0.0, 0.0, 0.0, 1.0),
	default_inactive_color = Vec4(0.2, 0.2, 0.2, 1.0),
	default_hover_color = Vec4(1.0, 0.0, 0.0, 1.0),
	default_mouse_down_color = Vec4(1.0, 1.0, 0.0, 1.0),
	default_font = Font:Load("Fonts/arial.ttf", 10),

	--scale modes
	ABSOLUTE = 0,
	AUTOSCALE = 1,
	ANCHOR = 2,

	--
	LEFT = 0,
	CENTER = 1,
	RIGHT = 2,
	MIDDLE = 3,
	TOP = 4,
	BOTTOM = 5
}

--I hate this function but I can't think of a way around it right now...
function THUI:Initialize()
	THUI.default_font = Font:Load("Fonts/arial.ttf", THUI:Rel2AbsY(10, 767) )
end

function THUI:CreateGroup(name, data, mode, anchorx, anchory, width, height)
	if THUI.groups[name] ~= nil then
		Debug("group: "..name.." already exists!")
	end

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
		qtree={},
		widgets={},
		Add=THUI.GroupAdd
	}
	
	group.qtree.left = 0
	group.qtree.top = 0
	group.qtree.right = ctx:GetWidth()
	group.qtree.bottom = ctx:GetHeight()

	qtree_subdivide(group.qtree, 4)

	
	THUI.groups[name] = group

	return group
end

function THUI:LookupByName(name)
	return self.groups[name].data
end

function THUI:Activate(name)
	local group = self.groups[name]

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

function THUI:Deactivate(name)
	local showmouse = false
	
	local wnd = Window:GetCurrent()
	wnd:FlushKeys()
	wnd:FlushMouse()

	if name == nil then
		for i=1, #self.active_groups do
			self.active_groups[i].active = false
		end

		self.active_groups = {}
	else
		local group = self.groups[name]
		
		if group.active then
			for i=1, #self.active_groups do
				if self.active_groups[i] == group then
					table.remove(self.active_groups, i)
				elseif self.active_groups[i].showmouse then
					showmouse = true
				end
			end
			group.active = false
		end
	end

	if not showmouse then
		wnd:HideMouse()
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

	for i=1, #self.active_groups do
		local active_group = self.active_groups[i]
		
		--draw
		ctx:SetBlendMode(Blend.Alpha)
		
		for k,v in pairs(active_group.widgets) do
			
			if v.visible then
				v:draw(ctx)
			end
		end

		if active_group.update ~= nil then
			self:DoCallback(active_group.update, active_group)
		end
		
		--do events
		local result = qtree_lookup(active_group.qtree, mouse_pos.x, mouse_pos.y)
		
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

function THUI:DoCallback(callback, widget)
	if callback[2] ~= nil then
		callback[1](callback[2], widget, callback[3])
	elseif callback[2] ~= nil then
		callback[1](arg, callback[3])
	end
end

function THUI:Rel2AbsX(x, max_value)
	return Context:GetCurrent():GetWidth() * x / max_value
end

function THUI:Rel2AbsY(y, max_value)
	return Context:GetCurrent():GetHeight() * y / max_value
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
	w = {
		x = THUI:_CalcJustifyX(x, width, justify_x),
		y = THUI:_CalcJustifyY(y, height, justify_y),
		width = width,
		height = height,
		fg_color = THUI.default_fg_color,
		bg_color = THUI.default_bg_color,
		inactive_color = THUI.default_inactive_color,
		visible = true
	}

	return w
end

function THUI:GroupAdd(widget)
	if widget.widgets ~= nil then
		for k,v in pairs(widget.widgets) do
			self:Add(v)
		end
	else
		if self.mode == THUI.AUTOSCALE then
			widget.x = THUI:Rel2AbsX(widget.x, self.width)
			widget.y = THUI:Rel2AbsY(widget.y, self.height)
			widget.width = THUI:Rel2AbsX(widget.width, self.width)
			widget.height = THUI:Rel2AbsY(widget.height, self.height)
		elseif self.mode == THUI.ANCHOR then
			local ctx = Context:GetCurrent()

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
		end

		if widget.interactive then
			qtree_insert(self.qtree, widget)
		end

		table.insert(self.widgets, widget)
	end
end