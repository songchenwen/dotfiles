hs.alert.closeAll()
local ignored = require 'ignored'

-- key define
local hyper = {'ctrl', 'alt', 'cmd'}
local hyperShift = {'ctrl', 'alt', 'cmd', 'shift'}

-- states
hs.window.animationDuration = 0

-- cli
if not hs.ipc.cliStatus() then hs.ipc.cliInstall() end

-- App shortcuts
local key2App = {
	q = 'QQ',
    w = 'Safari',
    x = 'Xcode',
    j = 'AppCode',
    a = 'Android Studio',
    s = 'Sublime Text 2',
    g = 'SourceTree',
    p = 'Adobe Photoshop CC',
    f = 'Finder',
    t = 'iTerm',
    n = 'Newsflow',
    c = 'Numi'
}
for key, app in pairs(key2App) do
	hs.hotkey.bind(hyper, key, function() hs.application.launchOrFocus(app) end)
end

-- Hints
hs.hotkey.bind(hyper, 'h', function() 
    hs.hints.windowHints(getAllValidWindows()) 
end)

-- undo
local undo = require 'undo'
hs.hotkey.bind(hyper, 'z', function() undo:undo() end)

-- Grids
hs.grid.GRIDWIDTH = 8
hs.grid.GRIDHEIGHT = 2
hs.grid.MARGINX = 0
hs.grid.MARGINY  = 0

local moveMaxWidth = hs.grid.GRIDWIDTH / 2 + 1
local moveMinWidth = hs.grid.GRIDWIDTH / 2 - 1

local hyperUp = hs.hotkey.bind(hyper, 'up', function() 
    undo:addToStack()
    hs.grid.maximizeWindow() 
end)


-- Move Window
function horizontalMove(direction)
    local w = hs.window.focusedWindow()
    if not w or not w:isStandard() then return end
    local s = w:screen()
    if not s then return end
    if ignored(w) then return end
    local g = hs.grid.get(w)
    g.y = 0
    g.h = hs.grid.GRIDHEIGHT
    direction = direction / math.abs(direction)

    if g.x + g.w == hs.grid.GRIDWIDTH and g.x == 0 then
        if direction < 0 then
            g.w = g.w - direction
            g.x = hs.grid.GRIDWIDTH - g.w
        else
            g.w = g.w + direction
        end
        undo:addToStack()
        hs.grid.set(w, g, s)
    end

    if g.x + g.w == hs.grid.GRIDWIDTH then
        g.w = g.w - direction
        local toMove = false
        if g.w > moveMaxWidth then
            g.w = moveMaxWidth
            g.x = 0
            toMove = true
        elseif g.w >= moveMinWidth then
            g.x = hs.grid.GRIDWIDTH - g.w
            toMove = true
        end
        if toMove then
            undo:addToStack()
            hs.grid.set(w, g, s)
            if direction > 0 and g.x + g.w >= hs.grid.GRIDWIDTH then
                w:ensureIsInScreenBounds()
            end
        end
        return
    end

    if g.x == 0 then
        g.w = g.w + direction
        local toMove = false
        if g.w > moveMaxWidth then
            g.w = moveMaxWidth
            g.x = hs.grid.GRIDWIDTH - moveMaxWidth
            toMove = true
        elseif g.w >= moveMinWidth then
            toMove = true
        end
        if toMove then
            undo:addToStack()
            hs.grid.set(w, g, s)
        end
        return
    end

    g.w = hs.grid.GRIDWIDTH / 2
    g.x = direction > 0 and hs.grid.GRIDWIDTH / 2 or 0
    undo:addToStack()
    hs.grid.set(w, g, s)
end

local hyperLeft = hs.hotkey.bind(hyper, 'left', function() horizontalMove(-1) end)

local hyperRight = hs.hotkey.bind(hyper, 'right', function() horizontalMove(1) end)

-- Move Screen
hs.hotkey.bind(hyperShift, 'left', function() 
    local w = hs.window.focusedWindow()
    if not w then 
        return
    end
    if ignored(w) then return end

    local s = w:screen():toWest()
    if s then
        undo:addToStack()
        w:moveToScreen(s)
    end
end)

hs.hotkey.bind(hyperShift, 'right', function() 
    local w = hs.window.focusedWindow()
    if not w then 
        return
    end
    if ignored(w) then return end
    
    local s = w:screen():toEast()
    if s then
        undo:addToStack()
        w:moveToScreen(s)
    end
end)

-- split view
SplitModal = require 'split_modal'
local splitModal = SplitModal.new(hyper, 'down', undo)

function splitModal:hotkeysToDisable()
    return {hyperUp, hyperRight, hyperLeft}
end

-- App layout
local AppLayout = {}
AppLayout['QQ'] = { small = true }
AppLayout['Safari'] = { small = true, full = true }
AppLayout['Sublime Text 2'] = { small = true }
AppLayout['SourceTree'] = { small = true }
AppLayout['Finder'] = { small = true }
AppLayout['iTerm'] = { small = true }
AppLayout['Newsflow'] = { small = true }
AppLayout['Xcode'] = { small = true, full = true, delay = 10 }
AppLayout['AppCode'] = { large = true, full = true, delay = 10 }
AppLayout['Android Studio'] = { large = true, full = true, delay = 10 }

function layoutApp(name, app, delayed)
    local conf = AppLayout[name]
    if not conf then return end

    if not delayed and conf.delay then
        print('delay layout '..name..' for '..conf.delay..' secs')
        hs.timer.doAfter(conf.delay, function() 
                layoutApp(name, app, true)
            end)
        return
    end
    
    if not app then app = hs.appfinder.appFromName(name) end
    local w = nil
    if app then w = app:mainWindow() end
    if not w then return end
    local s = nil
    if conf.small then
        print('move app '..name..' to smallerScreen')
        s = smallerScreen
    end
    if conf.large then
        print('move app '..name..' to largerScreen')
        s = largerScreen
    end
    if s and w:screen() and s ~= w:screen() then w:moveToScreen(s) end

    if conf.full and w:screen() then
        print('maximize app '..name)
        w:maximize()
    end
end

function applicationWatcherCallback(name, event, app)
    if event == hs.application.watcher.launched then
        layoutApp(name, app)
    end
end

local appWatcher = hs.application.watcher.new(applicationWatcherCallback)
appWatcher:start()

-- screen change
function screenChanged()
    local ss = hs.screen.allScreens()
    local count = #ss
    if count ~= lastNumberOfScreens then
        lastNumberOfScreens = count
        local largest = 0
        for i = 1, lastNumberOfScreens do
            local s = ss[i]
            local size = s:frame().w * s:frame().h
            local preSmall = smallerScreen
            smallerScreen = s
            if size > largest then
                largest = size
                largerScreen = s
                if preSmall then smallerScreen = preSmall end
            end
        end
        print('NumberOfScreens '.. lastNumberOfScreens)
        for app, conf in pairs(AppLayout) do
            layoutApp(app, nil, true)
        end
    end
end

screenChanged()

local screenWatcher = hs.screen.watcher.new(screenChanged)
screenWatcher:start()

-- caffeinate
hs.hotkey.bind(hyperShift, 'c', function() 
    local c = hs.caffeinate
    if not c then return end
    if c.get('displayIdle') or c.get('systemIdle') or c.get('system') then
        if menuCaff then
            menuCaffRelease()
        else
            addMenuCaff()
            local type
            if c.get('displayIdle') then type = 'displayIdle' end
            if c.get('systemIdle') then type = 'systemIdle' end
            if c.get('system') then type = 'system' end
            hs.alert('Caffeine already on for '..type)
        end
    else
        acAndBatt = hs.battery.powerSource() == 'Battery Power'
        c.set('system', true, acAndBatt)
        hs.alert('Caffeinated '..(acAndBatt and '' or 'on AC Power'))
        addMenuCaff()
    end
end)

function addMenuCaff()
    menuCaff = hs.menubar.new()
    menuCaff:setIcon("caffeine-on.pdf") 
    menuCaff:setClickCallback(menuCaffRelease)
end

function menuCaffRelease()
    local c = hs.caffeinate
    if not c then return end
    if c.get('displayIdle') then
        c.set('displayIdle', false, true)
    end
    if c.get('systemIdle') then
        c.set('systemIdle', false, true)
    end
    if c.get('system') then
        c.set('system', false, true)
    end
    if menuCaff then
        menuCaff:delete()
        menuCaff = nil
    end
    hs.alert('Decaffeinated')
end

-- console
hs.hotkey.bind(hyperShift, ';', hs.openConsole)

-- reload
hs.hotkey.bind(hyper, 'escape', function() hs.reload() end )

-- utils
function getAllValidWindows ()
    local allWindows = hs.window.allWindows()
    local windows = {}
    local index = 1
    for i = 1, #allWindows do
        local w = allWindows[i]
        if w:screen() then
            windows[index] = w
            index = index + 1
        end
    end
    return windows
end

hs.alert('Hammerspoon', 0.6)