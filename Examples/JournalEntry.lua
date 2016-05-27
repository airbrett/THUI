--The Hankinator's UI library

import "Addons/THUI/THUI.lua"

Script.index = 3
Script.title = "Entry 3"

function Script:Start()
	local font = Font:Load("Fonts/arial.ttf", THUI:Rel2AbsY(16, 767))

	local text = {
	"Day 45",
	"",
	"I have earned the Germans' trust.",
	"They still do not realize I am a bear."
	}

	self.grp = THUI:CreateGroup("entry1", self, THUI.AUTOSCALE, nil, nil, 1023, 767)

	local label = THUI.Label:Create(512, 10, 0, 0, self.title, THUI.CENTER, THUI.MIDDLE)
	label.font = font

	self.grp:Add(label)

	local y = 150
	local leading = font:GetHeight() * 1.3
	for i=0, #text do
		label = THUI.Label:Create(512, y, 0, 0, text[i], THUI.CENTER, THUI.MIDDLE)
		label.font = font
		self.grp:Add(label)
		y = y + leading
	end

	local journal_button = THUI.Button:Create(100, 700, 200, 50, "Journal")
	journal_button.click = THUI:Callback(self.JournalButtonClick, self, nil)

	self.grp:Add(journal_button)
end

function Script:Use()
	THUI:LookupByName("journal"):AddJounalEntry(self)
	THUI:Show("entry1")
	THUI:PauseGame(true)
	self.entity:Hide()
end

function Script:JournalButtonClick(button, arg)
	THUI:Hide("entry1")
	THUI:Show("journal")
end