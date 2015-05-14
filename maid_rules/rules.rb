#!/usr/bin/ruby
# Need `brew install tag` to manage Finder tags

require 'pathname'

Maid.rules do
	rule "test_run" do
		total_run()
	end

	watch('~/Downloads', {wait_for_delay: 10, ignore: [/\.crdownload$/, /\.download$/, /\.aria2$/, /\.td$/, /\.td.cfg$/]}) do
		rule 'Downloads Change' do |modified, added, removed|
			if added.any?() || removed.any?()
				newly() 
				movie_in_downloads()
				psd_in_downloads()
			end
		end
	end

	watch('~/Desktop', {wait_for_delay: 10, ignore: [/\.crdownload$/, /\.download$/, /\.aria2$/, /\.td$/, /\.td.cfg$/]}) do
		rule 'Desktop Change' do |modified, added, removed|
			newly() if added.any?()
		end
	end

	watch('~/Movies/Video/', {wait_for_delay: 10, ignore: [/\.crdownload$/, /\.download$/, /\.aria2$/, /\.td$/, /\.td.cfg$/]}) do
		rule 'Video Change' do |modified, added, removed|
			if added.any?()
				newly()	
				video_series()
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

	TagUnfinished = "未完"
	TagWork = "工作"
	TagPersonal = "个人"
	TagProject = "项目"
	TagFavorite = "最爱"
	TagSystem = "系统"

	def tags(path)
		path = sh_escape(expand(path))
		raw = cmd("tag -lN #{path}")
		raw.strip.split(',')
	end

	def has_tags?(path)
		ts = tags(path)
		ts && ts.count > 0
	end

	def contains_tag?(path, tag)
		path = expand(path)
		ts = tags(path)
		ts.include? tag
	end

	def add_tag(path, tag)
		path = expand(path)
		ts = Array(tag).join(",")
		log "add tags #{ts} to #{path}"
		cmd("tag -a #{ts} #{sh_escape(path)}")
	end

	def remove_tag(path, tag)
		path = expand(path)
		ts = Array(tag).join(",")
		puts "remove tags #{ts} from #{path}"
		log "remove tags #{ts} from #{path}"
		`tag -r "#{ts}" "#{path}"`
	end

	def set_tag(path, tag)
		path = expand(path)
		ts = Array(tag).join(",")
		puts "set tags #{ts} to #{path}"
		log "set tags #{ts} to #{path}"
		`tag -s "#{ts}" "#{path}"`
	end

	def tools_downloading?(path)
		aria2_downloading?(path) || thunder_downloading?(path)
	end

	def aria2_downloading?(path)
		File.exist?("#{path}.aria2") || path =~ /\.aria2$/
	end

	def thunder_downloading?(path)
		path =~ /\.td$/ || path =~ /\.td.cfg$/
	end

	def hidden(path)
		attribute = 'kMDItemFSInvisible'
		raw = cmd("mdls -raw -name #{attribute} #{ sh_escape(path) }")
		return raw == '1'
	end

	def has_been_used?(path)
		path = expand(path)
		raw = cmd("mdls -raw -name kMDItemLastUsedDate #{ sh_escape(path) }")
		if raw == "(null)"
			return false
		end
		begin
			DateTime.parse(raw).to_time
			return true
		rescue Exception => e
			return false
		end
	end

	def used_at(path)
		path = expand(path)
		raw = cmd("mdls -raw -name kMDItemLastUsedDate #{ sh_escape(path) }")
		if raw == "(null)"
			return 3650.day.ago
		end
		begin
			return DateTime.parse(raw).to_time
		rescue Exception => e
			return accessed_at(path)
		end
	end

	def added_at(path)
		path = expand(path)
		raw = cmd("mdls -raw -name kMDItemDateAdded #{ sh_escape(path) }")
		if raw == "(null)"
			return 1.second.ago
		end
		begin
			return DateTime.parse(raw).to_time
		rescue Exception => e
			return created_at(path)
		end
	end

	def is_empty_folder?(path)
		File.directory?(path) && dir("#{path}/*").select { |p| !hidden(p) }.count == 0
	end
	
	def dir_downloading(path)
		dir(path).select { |p| !hidden(p) && (downloading?(p) || tools_downloading?(p))}
	end

	def dir_not_downloading(path)
		dir_safe(path).reject { |path| hidden(path) || downloading?(path) || tools_downloading?(path)}
	end

end
