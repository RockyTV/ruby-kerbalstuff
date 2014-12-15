module kerbalstuff
	class Mod
		
		attr_reader :json
		
		def initialize json
			@json = json
			
			@name = @json['name']
			@background = @json['background']
			@license = @json['license']
			@website = @json['website']
			@donations = @json['donations']
			@source_code = @json['source_code']
			@author = @json['author']
			@downloads = @json['downloads']
			@id = @json['id']
			@short_description = @json['short_description']
			@description_html = @json['description_html']
			@followers = @json['followers']
			@default_version_id = @json['default_version_id']
			@description = @json['description']
			
			if @json.has_key?('versions')
				@versions = []
				if @json['versions'].length > 0
					@json['versions'].each do |v|
						@versions.push(ModVersion.new(v))
					end
				end
			end
			
		end
		
		def to_s
			return ["name=#{@name}", "background=https:""/""/""cdn.mediacru.sh#{@background}", "license=#{@license}", "website=#{@website}", "donations=#{@donations}", "source_code=#{@source_code}", "author=#{@author}", "downloads=#{@downloads}", "id=#{@id}", "short_description=\"#{@short_description}\"", "versions=#{@versions}", "description_html=\"#{@description_html}\"", "followers=#{@followers}", "default_version_id=#{@default_version_id}", "description=\"#{@description}\""]
		end
	end
	
	class ModVersion
	
		attr_reader :json
		
		def initialize json
			@json = json
			
			@version = @json['friendly_version']
			@download_path = @json['download_path']
			@id = @json['id']
			@ksp_version = @json['ksp_version']
			@changelog = @json['changelog']
		end
		
		def to_s
			["version=#{@version}", "download=https:""/""/""kerbalstuff.com#{@download_path}", "id=#{@id}", "ksp_version=#{@ksp_version}", "changelog=\"#{@changelog}\""]
		end
	end
end