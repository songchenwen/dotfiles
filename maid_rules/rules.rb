#!/usr/bin/ruby
# Need `brew install tag` to manage Finder tags

require 'pathname'

Maid.rules do
	rule "test_run" do
		total_run
	end

	watch '~/Downloads' do
		rule 'Downloads Change' do |modified, added, removed|
			new_added(added) 
			movie_in_downloads()
			psd_in_downloads()
		end
	end

	watch '~/Desktop' do
		rule 'Desktop Change' do |modified, added, removed|
			new_added(added)
		end
	end

	watch '~/Movies/Video' do
		rule 'Video Change' do |modified, added, removed|
			if added.any?()
				new_added(added)	
				video_series()
				video_convert()
			end
		end
	end

	repeat '15m' do
		rule '15m' do
			total_run()
		end
	end

	repeat '1d' do
		rule 'Update System' do
			pid = Process.spawn("brew update;brew upgrade --all")
			Process.detach pid
			pid = Process.spawn("npm update -g")
			Process.detach pid
			pid = Process.spawn("gem update !psych")
			Process.detach pid
			pid = Process.spawn("node ~/Documents/dotfiles/bloomfilter-pac/index.js")
			Process.detach pid
		end
	end

	def total_run
		movie_in_downloads()
		psd_in_downloads()
		dmg_in_downloads()
		file_openned()
		trash_old()
		video_series()
		video_convert()
	end

	def new_added(added)
		added =	added.select do |path|
			path = expand(path)
			p = Pathname.new(path)
			p.dirname.to_s == expand('~/Movies/Video') || p.dirname.to_s == expand('~/Desktop') || p.dirname.to_s == expand('~/Downloads')
		end
		if added && added.any? then
			added.each do |path|
				unless has_tags?(path) || File.directory?(path)
					add_tag(path, TagUnfinished) unless has_been_used?(path)
				end
			end
		end
	end

	def movie_in_downloads
		where_content_type(dir_not_downloading('~/Downloads/*'), ['video', 'public.movie']).each do |path|
			move(path, '~/Movies/Video/') if duration_s(path) > 15 * 60
		end
	end

	def psd_in_downloads
		dir_not_downloading('~/Downloads/*.psd').each do |path|
			remove_tag(path, TagUnfinished)
			move(path, '~/Documents/pic_source/')
		end
	end

	def dmg_in_downloads
		dir_not_downloading('~/Downloads/*.{exe,deb,dmg,pkg,zip,app,safariextz}').each do |path|
			if contains_tag?(path, TagSystem) && !contains_tag?(path, TagUnfinished)
				remove_tag(path, TagSystem)
				move(path, '~/Documents/apps2install/')
			end
		end
	end

	def file_openned
		dir_not_downloading('~/{Downloads}/*').each do |path|
			if has_been_used?(path) && contains_tag?(path, TagUnfinished)
				remove_tag(path, TagUnfinished)
			end
		end
	end

	def trash_old
		dir_not_downloading('~/{Downloads,Desktop}/*').each do |path|
			if File.directory?(path) && !is_empty_folder?(path)
				log "trash ignore none empty folder #{path}"
			else
				trash(path) if !has_tags?(path) && has_been_used?(path) && 1.day.since?(used_at(path)) && 2.day.since?(added_at(path))
			end
		end

		where_content_type(dir_not_downloading('~/Movies/Video/*'), ['video', 'public.movie']).each do |path|
			trash(path) if !has_tags?(path) && has_been_used?(path) && 1.day.since?(used_at(path))
		end
		where_content_type(dir_not_downloading('~/Movies/Video/**/*'), ['video', 'public.movie']).each do |path|
			trash(path) if !has_tags?(path) && has_been_used?(path) && 1.day.since?(used_at(path))
		end

		dir_not_downloading('~/Movies/Video/*').each do |path|
			if is_empty_folder?(path)
				remove(path) if has_been_used?(path) && 1.day.since?(used_at(path))
			end
		end

		dir('~/.Trash/*').each do |path|
			remove(path) if 1.week.since?(added_at(path))
		end
	end

	VideoSeriesNameMinPrefixLength = 3
	VideoSeriesNameMaxPrefixLength = 20

	def video_series
		where_content_type(dir_not_downloading('~/Movies/Video/*'), ['video', 'public.movie']).each do |path|
			path = expand(path)
			p = Pathname.new(path)
			name = p.basename.to_s
			prefix = name[0, VideoSeriesNameMinPrefixLength]
			sameSeriesInFolder = where_content_type(dir_not_downloading("~/Movies/Video/*/#{prefix}*"), ['video', 'public.movie']).reject do |e|
				ep = Pathname.new(e)
				expand(e) == path || ep.basename.to_s[0..(0 - ep.extname().length)] == name[0..(0 - p.extname().length)]	
			end
			if sameSeriesInFolder.any? then
				move(path, Pathname.new(expand(sameSeriesInFolder[0])).dirname.to_s)
			else
				sameSeries = where_content_type(dir_not_downloading("~/Movies/Video/#{prefix}*"), ['video', 'public.movie']).reject do |e|
					ep = Pathname.new(e)
					expand(e) == path || ep.basename.to_s[0..(0 - ep.extname().length)] == name[0..(0 - p.extname().length)]
				end
				if sameSeries.any? then
					first = Pathname.new(expand(sameSeries[0])).basename.to_s
					prefixLength = VideoSeriesNameMinPrefixLength
					VideoSeriesNameMinPrefixLength.upto([name.length, first.length, VideoSeriesNameMaxPrefixLength].min) do |i|
						prefixLength = i
						if not name[0, i] == first[0, i] then
							break
						end
					end
					folderName = name[0, prefixLength]
					dest = "~/Movies/Video/#{folderName}"
					mkdir(dest)
					move(path, dest)
				end
			end
		end

	end

	def video_convert
		if is_on_battery?() 
			return 
		end
		where_content_type(dir_not_downloading('~/Movies/{Video/,Video/**/}*\.{rmvb,flv}'), ['video', 'public.movie']).each do |path|
			if not contains_tag?(path, TagUnfinished) then
				return
			end
			path = expand(path)
			p = Pathname.new(path)
			ext = p.extname()
			out = path[0, path.length - ext.length] + ".mkv"
			if File.exist?(out) then
				return
			end
			if path =~ /\.rmvb$/
				log "convert #{path}"
				cmd("ffmpeg -i #{sh_escape(path)} -c:v libx264 -preset veryfast -crf 18 -c:a copy -map_metadata -1 #{sh_escape(out)} && rm #{sh_escape(path)}")
				add_tag(out, TagUnfinished)
			end
			if path =~ /\.flv$/
				log "convert #{path}"
				cmd("ffmpeg -i #{sh_escape(path)} -c copy #{sh_escape(out)} && rm #{sh_escape(path)}")
				add_tag(out, TagUnfinished)
			end
		end
	end

	TagUnfinished = "未完"
	TagWork = "工作"
	TagPersonal = "个人"
	TagProject = "项目"
	TagFavorite = "最爱"
	TagSystem = "系统"

	def is_empty_folder?(path)
		File.directory?(path) && dir("#{path}/*").select { |p| !hidden?(p) }.count == 0
	end

	def is_on_battery?
		if cmd("pmset -g ps | grep AC").length > 0
			return false
		else
			return true
		end
	end
	
	def dir_downloading(path)
		dir(path).select { |p| !hidden?(p) && downloading?(p) }
	end

	def dir_not_downloading(path)
		dir_safe(path).reject { |path| hidden?(path) }
	end

end
