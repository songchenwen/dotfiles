local ignored_apps = {
	'QQ',
	'微信',
	'Newsflow',
	'SourceTree',
    'iTerm'
}

function ignored(win)
	local app = win:application()
	if app then
		local title = app:title()
		print('identifier'..title)
		return hs.fnutils.contains(ignored_apps, title)
	end
	return false
end

return ignored
