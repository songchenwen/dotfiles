-- This script automatically remove the Unfinished label

utils = require 'mp.utils'

DEBUG = false
FILE_END_SECONDS = 9 * 60
TAG_UNFINISHED = '未完'

local path

function markFinished()
	osdShow('Unobserve progress')
	mp.unobserve_property(checkTimeRemaining)

	if not path then return end

	mp.msg.info('Mark finished', path)
	local result = utils.subprocess({args = {'/usr/local/bin/tag', '-r', TAG_UNFINISHED, path}, cancellable = false})
	path = nil
	
	if result.status == 0 then 
		mp.osd_message('Finished')
	end
end

function checkHasTag()
	local hasTag = utils.subprocess({args = {'which', '-s', '/usr/local/bin/tag'}, cancellable = false})
	if hasTag.status == 0 then
		return true
	else
		mp.msg.warn('Not have tag', hasTag.status, hasTag.error)
		return false
	end
end

function hasUnfinishedTag()
	if checkHasTag() then 
		if not path then return false end

		local tags = utils.subprocess({args = {'/usr/local/bin/tag', '-lN', path}, cancellable = false})

		if tags.status == 0 then
			return string.find(tags.stdout, TAG_UNFINISHED) ~= nil
		else
			mp.msg.warn('List tag failed', tags.status, tags.error)
			return false
		end
	else
		return false
	end
end

function onNewFile(event)
	path = mp.get_property('path')
	osdShow('New file '..path)
	mp.unobserve_property(checkTimeRemaining)
	if hasUnfinishedTag() then
		mp.msg.info('Observe progress for', path)
		osdShow('Observe progress')
		mp.observe_property('time-remaining', 'number', checkTimeRemaining)
	end
end

function osdShow(msg)
	if DEBUG then mp.osd_message(msg) end
end

function checkTimeRemaining(name, timeRemaining)
	if timeRemaining < FILE_END_SECONDS then 
		markFinished()
	end
end

mp.register_event('start-file', onNewFile)
