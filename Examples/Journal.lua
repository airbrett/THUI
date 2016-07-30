--The Hankinator's UI library

import "Addons/THUI/THUI.lua"

function Script:Start()
	Journal = self --global that entries can use to add themselves

	self.pg = THUI:CreateGroup("journal", self, THUI.AUTOSCALE, nil, nil, 1023, 767)

	local font = 24
	local title = THUI.Label:Create(512, 50, 0, 0, "Journal", THUI.CENTER, THUI.MIDDLE)
	title.font = font

	local button1 = THUI.Button:Create(50, 700, 200, 50, "Resume")

	button1.click = THUI:Callback(self.ResumeButtonClicked, self)

	self.pg:Add(title)
	self.pg:Add(button1)
	
	self.entries = {}
	self.entry_buttons = {}

	for i=1, 10 do
		local b = THUI.Button:Create(512, 45 + 55 * i, 200, 50, "????", THUI.CENTER, THUI.MIDDLE)
		b.active = false
		b.click = THUI:Callback(self.EntryButtonClicked, self, i)
		self.pg:Add(b)
		self.entry_buttons[i] = b
	end

	self.journal_entry = THUI:CreateGroup("journal_entry", self)

end

function Script:UpdateWorld()
	if window:KeyHit(Key.J) then
		if not THUI:GamePaused() then
			THUI:PauseGame(true)
			THUI:Show(self.pg)
		end
	end
end

function Script:EntryButtonClicked(button, index)
	THUI:Hide("journal")
	THUI:Show(self.entries[index].grp.name)
end

function Script:ResumeButtonClicked(button)
	THUI:PauseGame(false)
	THUI:Hide(self.pg)

	--FPSPlayer.lua measures the distance from the middle of the screen to figure out how much
	--the player is trying to look so we need to reset it when the user is done with the UI
	local context = Context:GetCurrent()
	Window:GetCurrent():SetMousePosition(Math:Round(context:GetWidth()/2), Math:Round(context:GetHeight()/2))
end

function Script:AddJounalEntry(entry)
	self.entries[entry.index] = entry
	
	local b = self.entry_buttons[entry.index]
	b.active = true
	b.text = entry.title
end