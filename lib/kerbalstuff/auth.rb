module kerbalstuff

	class NotLoggedInException < Exception
	end
	
	class LoginException < Exception
	end
	
	class ErrorException < Exception
	end

	class Auth
	
		# @api private
		attr_accessor :cookie
	
		# Logs into Kerbal Stuff.
		#
		# @param params [Hash] Login parameters.
		# @option params [String] :username kerbalstuff account username
		# @option params [String] :password kerbalstuff account password
		# @return [Array] An array with the status of the login.	
		def self.login(params = {})
			@username = params['username']
			@password = params['password']
			
			url = URI.parse("https://kerbalstuff.com/api/login")
			
			http = Net::HTTP.new(url.host, url.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			
			req = Net::HTTP::Post::Multipart.new url.path, "username" => @username, "password" => @password
			
			res = http.start do |http2|
				http2.request(req)
			end
			
			resp = JSON.parse(res.body)
			if resp['error'] == false
				@cookie = res.header['set-cookie']
				return ["error=false", "info=Logged in successfully."]
			else
				return ["error=true", "info=#{resp['reason']}"]
			end
		end
		
		# Creates a new mod. Requires authentication.
		#
		# @param params [Hash] Create mod parameters.
		# @option params [String] :name Your new mod's name
		# @option params [String] :desc Short description of your mod
		# @option params [String] :version The latest friendly version of your mod
		# @option params [String] :ksp_ver The KSP version this is compatible with
		# @option params [String] :license Your mod's license
		# @option params [File] :zipball The actual mod's zip file. FOR NEWBIES: path to the mod zip file.
		# @return [Array] An array containing the published mod info.
		def self.create_mod(params = {})
			@name = params['name']
			@desc = params['desc']
			@version = params['version']
			@ksp_ver = params['ksp_ver']
			@license = params['license']
			@zipball = params['zipball']
			
			url = URI.parse("https://kerbalstuff.com/api/mod/create")
			
			http = Net::HTTP.new(url.host, url.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			
			File.open(@zipball, "r") do |file|
			
				req = Net::HTTP::Post::Multipart.new url.path, "name" => @name, "short-description" => @desc, "version" => @version, "ksp-version" => @ksp_ver, "license" => @license, 
					"zipball" => UploadIO.new(file, "application/zip", File.basename(file))
				req.add_field("Cookie", @cookie)
			
				res = http.start do |http2|
					http2.request(req)
				end
				
				resp = JSON.parse(res.body)
				
				if resp['error'] == true
					return ["error=true", "msg=#{resp['reason']}"]
				else
					return ["id=#{resp['id']}", "name=#{resp['name']}", "url=http:""/""/""kerbalstuff.com#{resp['url']}"]
				end
			end
			
		end
		
		# Publishes an update to an existing mod. Requires authentication. All parameters are required. Parameters are passed by via Hash.
		#
		# @param [Hash] params Update mod parameters
		# @option params [Fixnum] :modid The ID of the mod you want to update
		# @option params [String] :version The friendly version number about to be created
		# @option params [String] :changelog Markdown changelog
		# @option params [String] :ksp_ver The version of KSP this is compatible with
		# @option params [String] :notify_followers If "yes", email followers about this update
		# @option params [File] :zipball The actual mod's zip file. FOR NEWBIES: path to the mod zip file.
		# @return [Array] A string containing the updated version info.
		# @raise [ArgumentError] If missing one or more parameters, or if one or more parameters are empty.
		def self.update_mod(params = {})
			raise ArgumentError, "Params cannot be empty" if params.empty?
			raise ArgumentError, "Missing one or more parameters" unless (params.has_key?("modid") && params.has_key?("version") && params.has_key?("changelog") && params.has_key?("ksp_ver") && params.has_key?("notify_followers") && params.has_key?("zipball"))
			
			modid = params['modid']
			@version = params['version']
			@changelog = params['changelog']
			@ksp_ver = params['ksp_ver']
			@notify_followers = params['notify_followers']
			@zipball = params['zipball']
			
			url = URI.parse("https://kerbalstuff.com/api/mod/#{modid}/update")
			
			http = Net::HTTP.new(url.host, url.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			
			File.open(@zipball, "r") do |file|
			
				req = Net::HTTP::Post::Multipart.new url.path, "version" => @version, "changelog" => @changelog, "ksp-version" => @ksp_ver, "notify-followers" => @notify_followers, 
					"zipball" => UploadIO.new(file, "application/zip", File.basename(file))
				req.add_field("Cookie", @cookie)
			
				res = http.start do |http2|
					http2.request(req)
				end
				
				resp = JSON.parse(res.body)
				
				if resp['error'] == true
					return ["error=true", "msg=#{resp['reason']}"]
				else
					return ["id=#{resp['id']}", "url=http:""/""/#{resp['url']}"]
				end
			end
		end
	end
end