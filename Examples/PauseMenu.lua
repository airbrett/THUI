--The Hankinator's UI library

--For this script to work, you need to modify your Main.lua to
--only call Time:Update() and world:Update() when paused is false.
--Take a look at the Main.lua in the example's directory

import "Addons/THUI/THUI.lua"

function Script:Start()
--Autoscale version
---[[
	self.group = THUI:CreateGroup("pause_menu", self, THUI.AUTOSCALE, nil, nil, 1023, 767)

	self.group.update = THUI:Callback(self.UpdateUI, self, nil)

	local title_font = Font:Load("Fonts/arial.ttf", THUI:Rel2AbsY(32, 767))
	local title = THUI.Label:Create(512, 50, 0, 0, "Paused!", THUI.CENTER, THUI.MIDDLE)
	title.font = title_font

	local width = 200
	local button1 = THUI.Button:Create(512, 300, width, 50, "Resume", THUI.CENTER, THUI.MIDDLE)

	button1.click = THUI:Callback(self.ResumeButtonClicked, self)
	
	local exitbutton = THUI.Button:Create(512, 400, width, 50, "Exit", THUI.CENTER, THUI.MIDDLE)
	exitbutton.click = THUI:Callback(self.ExitButtonClicked, self)

	self.group:Add(title)
	self.group:Add(button1)
	self.group:Add(exitbutton)
--]]

--Anchored version
--[[
	self.group = THUI:CreateGroup("pause_menu", self, THUI.ANCHOR, THUI.LEFT, THUI.MIDDLE, 200, 200)

	self.group.update = THUI:Callback(self.UpdateUI, self, nil)

	local title_font = Font:Load("Fonts/arial.ttf", THUI:Rel2AbsY(32, 767))
	local title = THUI.Label:Create(100, 0, 0, 0, "Paused!", THUI.CENTER, THUI.TOP)
	title.font = title_font

	local button1 = THUI.Button:Create(0, 50, 200, 50, "Resume")

	button1.click = THUI:Callback(self.ResumeButtonClicked, self)
	
	local exitbutton = THUI.Button:Create(0, 150, 200, 50, "Exit")
	exitbutton.click = THUI:Callback(self.ExitButtonClicked, self)

	self.group:Add(title)
	self.group:Add(button1)
	self.group:Add(exitbutton)
--]]

--Absolute version
--[[
	self.group = THUI:CreateGroup("pause_menu", self, THUI.ABSOLUTE)

	self.group.update = THUI:Callback(self.UpdateUI, self, nil)

	local title_font = Font:Load("Fonts/arial.ttf", THUI:Rel2AbsY(32, 767))
	local title = THUI.Label:Create(400, 200, 0, 0, "Paused!", THUI.CENTER, THUI.TOP)
	title.font = title_font

	local button1 = THUI.Button:Create(300, 250, 200, 50, "Resume")

	button1.click = THUI:Callback(self.ResumeButtonClicked, self)
	
	local exitbutton = THUI.Button:Create(300, 350, 200, 50, "Exit")
	exitbutton.click = THUI:Callback(self.ExitButtonClicked, self)

	self.group:Add(title)
	self.group:Add(button1)
	self.group:Add(exitbutton)
--]]
end

function Script:ResumeButtonClicked(button)
	self:HideMenu()
end

function Script:ExitButtonClicked(button)
	exit_game = true
end

function Script:UpdateWorld()
	if window:KeyHit(Key.Escape) then
		if not paused then
			self:ShowMenu()
		end
	end
end

function Script:UpdateUI(group, arg)
	if window:KeyHit(Key.Escape) then
		if paused then
			self:HideMenu()
		end
	end
end

function Script:ShowMenu()
	TH.PauseGame(true)
	THUI:Show("pause_menu")
end

function Script:HideMenu()
	TH.PauseGame(false)
	THUI:Hide("pause_menu")

	--FPSPlayer.lua measures the distance from the middle of the screen to figure out how much
	--the player is trying to look so we need to reset it when the user is done with the UI
	local context = Context:GetCurrent()
	Window:GetCurrent():SetMousePosition(Math:Round(context:GetWidth()/2), Math:Round(context:GetHeight()/2))
end