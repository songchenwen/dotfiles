SplitModal = {}
SplitModal.__index = SplitModal

local ignored = require 'ignored'

function SplitModal.new(mods, key, undo)
	local m = {}
	setmetatable(m, SplitModal)
	m.key = hs.hotkey.modal.new(mods, key)
	m.undo = undo
	m.stickedWindow = nil
	m.windows = {}
	m.otherWindow = nil
	m.splitPoint = hs.grid.GRIDWIDTH / 2
	m.otherOriRect = nil
	m.line = nil
	
	m.key:bind({}, 'escape', function() 
    	m.key:exit() 
	end)
	m.key:bind({}, 'return', function() 
    	m.key:exit() 
	end)

	m.key:bind({}, 'up', function()
	    m:_moveBetweenWindows(1)
	end)

	m.key:bind({}, 'down', function()
	    m:_moveBetweenWindows(-1)
	end)

	m.key:bind({}, 'left', function()
		if m.splitPoint < hs.grid.GRIDWIDTH / 2 then return end
		m.splitPoint = m.splitPoint - 1
		m:_layout()
	end)

	m.key:bind({}, 'right', function()
		if m.splitPoint > hs.grid.GRIDWIDTH / 2 then return end
		m.splitPoint = m.splitPoint + 1
		m:_layout()
	end)

	function m.key:entered()
		m:entered()
	end
	
	function m.key:exited()
		m:exited()
	end

	return m
end

function SplitModal:entered()
	local w = hs.window.focusedWindow()
	if w and w:isStandard() and not ignored(w) then
		self:_switchStickedWindow(w)
	else
        self.key:exit()
        return
	end
	if #self.windows > 0 then
		self.splitPoint = hs.grid.GRIDWIDTH / 2
		self.otherWindow = self.windows[1]
		self.otherOriRect = nil
		self.line = nil
		self:_layout()
   		self.undo.skip = true
		local ks = self:hotkeysToDisable()
		if ks then
			local count = #ks
			for i = 1, count do
				ks[i]:disable()
			end
		end
	else
		hs.alert('No Window to Split') 
        self.key:exit()
        return
	end
end

function SplitModal:_layout()
	local s = self.stickedWindow:screen()
	self.otherOriRect = self.otherWindow:frame()

	if not self.undo.skip then
		self.undo:addToStack({self.stickedWindow, self.otherWindow})
	else
		local status = self.undo.stack[#self.undo.stack]
		local ww = nil
		local ff = nil
		for w, f in pairs(status) do 
			if w ~= self.stickedWindow then
				status[w] = nil
			end
		end
		status[self.otherWindow] = self.otherWindow:frame()
		self.undo.stack[#self.undo.stack] = status
	end
	
	hs.grid.set(self.stickedWindow, hs.geometry.rect(0, 0, self.splitPoint, hs.grid.GRIDHEIGHT), s)
	hs.grid.set(self.otherWindow, hs.geometry.rect(self.splitPoint, 0, hs.grid.GRIDWIDTH - self.splitPoint, hs.grid.GRIDHEIGHT), s)
	self:drawLine()
	self.otherWindow:focus()
	self.stickedWindow:focus()
end

function SplitModal:drawLine()
	if self.line then self.line:delete() end
	local f = self.stickedWindow:frame()
	self.line = hs.drawing.line({x = f.x + f.w, y = f.y}, {x = f.x + f.w, y = f.y + f.h})
	self.line:setStroke(true) 
	self.line:setStrokeColor({red = 0.8, green = 0.4, blue = 0.7, alpha = 0.9})
	self.line:setStrokeWidth(6)
	self.line:show()
end

function SplitModal:_switchStickedWindow(w)
	self.stickedWindow = w
	self.windows = {}
	local app = w:application()
	self:_addWindows(app:visibleWindows())
	self:_addWindows(w:otherWindowsSameScreen())
	self:_addWindows(w:otherWindowsAllScreens())
end

function SplitModal:_addWindows(ws)
	local size = #ws
	for i = 1, size do
		local w = ws[i]
		if w:screen() and w ~= self.stickedWindow and not hs.fnutils.contains(self.windows, w) and not ignored(w) and w:isStandard() then
			self.windows[#self.windows + 1] = w
		end
	end
end

function SplitModal:_moveBetweenWindows(direction)
	local prevW = self.otherWindow
	local prevWFrame = self.otherOriRect
	local index = hs.fnutils.indexOf(self.windows, prevW)
	index = index + direction
    if index > #self.windows then
        index = 1
    end
    if index < 1 then
        index = #self.windows
    end
    local nextW = self.windows[index]
    if nextW then
    	if prevWFrame then prevW:setFrame(prevWFrame) end
    	self.otherWindow = nextW
    	self:_layout()
    end
end

function SplitModal:hotkeysToDisable()
	return nil
end

function SplitModal:exited()
	self.stickedWindow = nil
	self.otherWindow = nil
	self.windows = nil
    self.undo.skip = false
    if self.line then
    	self.line:delete()
    	self.line = nil
    end
	local ks = self:hotkeysToDisable()
	if ks then
		local count = #ks
		for i = 1, count do
			ks[i]:enable()
		end
	end
end

return SplitModal