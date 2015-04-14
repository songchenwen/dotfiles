local undo = {
	stack = {},
	stackMax = 100,
	skip = false,
}

function undo:addToStack(wins)
	if self.skip then return end
    if not wins then wins = { hs.window.focusedWindow() } end
    local size = #self.stack
    self.stack[size + 1] = self:getCurrentWindowsLayout(wins)
    size = size + 100
    if size > self.stackMax then
        for i = 1, size - self.stackMax do
            self.stack[1] = nil
        end
    end
end

function undo:undo()
	local size = #self.stack
    if size > 0 then
        local status = self.stack[size]
        for w, f in pairs(status) do 
            if w and f and w:isVisible() and w:isStandard() and w:id() then
                if not compareFrame(f, w:frame()) then
                    w:setFrame(f)
                end
            end
        end
        self.stack[size] = nil
    else
        hs.alert('Reach Undo End', 0.5)
    end
end

function undo:getCurrentWindowsLayout(wins)
    if not wins then wins = { hs.window.focusedWindow() } end
    local current = {}
    for i = 1, #wins do
        local w = wins[i]
        local f = w:frame()
        if w:isVisible() and w:isStandard() and w:id() and f then
            current[w] = f
        end
    end
    return current
end

function compareFrame(t1, t2)
    if t1 == t2 then return true end
    if t1 and t2 then
        return t1.x == t2.x and t1.y == t2.y and t1.w == t2.w and t1.h == t2.h
    end
    return false
end

return undo