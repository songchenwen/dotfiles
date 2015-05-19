#!/usr/bin/ruby
# Need `brew install tag` to manage Finder tags

require 'pathname'

Maid.rules do
	rule "test_run" do
		total_run()
	end

	watch '~/Downloads' do
		rule 'Downloads Change' do
			newly() 
			movie_in_downloads()
			psd_in_downloads()
		end
	end

	watch '~/Desktop' do
		rule 'Desktop Change' do |modified, added, removed|
			newly() if added.any?()
		end
	end

	watch '~/Movies/Video/' do
		rule 'Video Change' do |modified, added, removed|
			if added.any?()
				newly()	
				video_series()
				video_convert()
			end
		end
	end

	repeat '30m' do
		rule '30m' do
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
		new_downloading()
		new_added()
		movie_in_downloads()
		psd_in_downloads()
		dmg_in_downloads()
		file_openned()
		trash_old()
		video_series()
		video_convert()
	end

	def newly
		new_downloading()
		new_added()
	end

	def new_downloading
		dir_downloading('~/{Downloads,Desktop,Movies/Video}/*').each do |path|
			add_tag(path, TagUnfinished)
		end
	end

	def new_added
		dir_not_downloading('~/{Downloads,Desktop,Movies/Video}/*').each do |path|
			unless has_tags?(path) 	
				added = added_at(path)
				if !30.minute.since?(added)
					used = used_at(path)
					if !used || used < added
						add_tag(path, TagUnfinished) 
					end
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
				trash(path) if !has_tags?(path) && 1.day.since?(used_at(path)) && 2.day.since?(added_at(path))
			end
		end

		where_content_type(dir_not_downloading('~/Movies/Video/*'), ['video', 'public.movie']).each do |path|
			trash(path) if !has_tags?(path) && 1.day.since?(used_at(path))
		end
		where_content_type(dir_not_downloading('~/Movies/Video/**/*'), ['video', 'public.movie']).each do |path|
			trash(path) if !has_tags?(path) && 1.day.since?(used_at(path))
		end

		dir_not_downloading('~/Movies/Video/*').each do |path|
			if is_empty_folder?(path)
				remove(path) if 1.day.since?(used_at(path))
			end
		end

		dir('~/.Trash/*').each do |path|
			remove(path) if 1.week.since?(used_at(path))
		end
	end

	def video_series
		rootDir = expand('~/Movies/Video/')
		folders = []
		dir_not_downloading('~/Movies/Video/*').each do |path|
			if File.directory?(path)
				folders.push(path[rootDir.length + 1, path.length - rootDir.length - 1])
			end
		end
		if folders.any?
			where_content_type(dir_not_downloading('~/Movies/Video/*'), ['video', 'public.movie']).each do |path|
				p = Pathname.new(expand(path))
				if p.dirname.to_s == rootDir
					name = p.basename.to_s.split('.')
					if name.count > 0
						name = name[0]
						move(path, "~/Movies/Video/#{name}") if folders.include?(name)
					end
				end
			end
		end

		first = []
		second = []
		where_content_type(dir_not_downloading('~/Movies/Video/*'), ['video', 'public.movie']).each do |path|
			rootDir = expand('~/Movies/Video')
			p = Pathname.new(expand(path))
			if p.dirname.to_s == rootDir
				name = p.basename.to_s.split('.')
				if name.count > 0
					name = name[0]
					second.push(name) if !second.include?(name) && first.include?(name)
					first.push(name) if !first.include?(name)
				end
			end
		end
		if second.any?
			second.each do |name|
				where_content_type(dir_not_downloading("~/Movies/Video/#{name}*"), ['video', 'public.movie']).each do |path|
					rootDir = expand('~/Movies/Video')
					p = Pathname.new(expand(path))
					dest = "~/Movies/Video/#{name}"
					mkdir(dest)
					if p.dirname.to_s == rootDir
						move(path, dest)
					end
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
