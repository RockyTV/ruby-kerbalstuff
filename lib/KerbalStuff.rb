require 'net/http'
require 'net/http/post/multipart'
require 'json'
require 'uri'

module kerbalstuff

	autoload :VERSION, 'kerbalstuff/version'
	autoload :Mod, 'kerbalstuff/mod'
	autoload :ModVerison, 'kerbalstuff/mod'
	autoload :User, 'kerbalstuff/user'
	autoload :Auth, 'kerbalstuff/auth'

	# @api private
	def self.get_https_response(url)
		@url = URI.parse(URI.escape(url))
		http = Net::HTTP.new(@url.host, @url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		
		request = Net::HTTP::Get.new(@url.request_uri)
		
		response = http.request(request)
		response
	end
	
	# @api private
	def self.get_json(url)
		response = get_https_response(url)
		json = JSON.parse(response.body)
		
		if json.is_a?(Hash)
			if json.has_key? 'error'
				return "error", "#{json['reason']}"
			else
				return json
			end
		else
			return json
		end
	end
	
	# Searches for mods with the specified keyword/phrase.
	#
	# @param query [String] the keyword/phrase to search for.
	# @return [Array] An array containing the results found. If no result was found, will return a String.
	def self.search_mod(query)
		res = get_json("https://kerbalstuff.com/api/search/mod?query=#{query}")
		
		resArr = []
		
		if res.length == 0
			return "No results were found for '#{query}'."
		else
			res.each do |mod|
				resArr.push(Mod.new(mod))
			end
			return resArr
		end
	end
	
	# Searches for users with the specified keyword/phrase.
	#
	# @param query [String] the keyword/phrase to search for.
	# @return [Array] An array containing the results found. If no result was found, will return a String.
	def self.search_user(query)
		res = get_json("https://kerbalstuff.com/api/search/user?query=#{query}")
		
		resArr = []
		
		if res.length == 0
			return "No results were found for '#{query}'."
		else
			res.each do |user|
				resArr.push(User.new(user))
			end
			return resArr
		end
	end
	
	# Retrieves the specified mod information.
	#
	# @param id [Integer] the id of the mod to retrieve information for.
	# @return [Mod] A Mod object containing the information about the mod.
	# @raise [ArgumentError] if "id" is not an Integer
	def self.get_mod(id)
		raise "id must be an Integer" unless id.is_a?(Integer)
		
		return Mod.new(get_json("https://kerbalstuff.com/api/mod/#{id}"))
	end
	
	# Retrieves the specified user information.
	#
	# @param username [String] the username of the user to retrieve information for.
	# @return [User] A User object containing the information about the user.
	# @raise [ArgumentError] if "username" is not a String
	# @raise [ArgumentError] if "username" is empty
	def self.get_user(username)
		raise ArgumentError, "username must be a String" unless username.is_a?(String)
		raise ArgumentError, "username cannot be an empty string" unless username.length > 0
		
		return User.new(get_json("https://kerbalstuff.com/api/user/#{username}"))
	end
	
	# Retrieves the latest version of the specified mod.
	#
	# @param id [Integer] the id of the mod to retrieve the latest version released.
	# @return [ModVersion] A ModVersion object containing information about the version.
	# @raise [ArgumentError] if "id" is not an Integer
	def self.get_latest_mod_version(id)
		raise ArgumentError, "id must be an Integer" unless id.is_a?(Integer)
		
		return ModVersion.new(get_json("https://kerbalstuff.com/api/mod/#{id}/latest"))
	end
	
	# Browse the website without authentication.
	# @param browse_params [Hash] browses the website with the specified parameters
	# @option browse_params [Integer] :page which page of results to retrieve. Valid values: 1-??? (optional)
	# @option browse_params [String] :orderby which property of mod use for ordering. Valid values are: name, updated, created. Default: created (required)
	# @option browse_params [String] :order which ordering direction to use. Valid values are: asc, desc. Default: asc (required)
	# @option browse_params [Fixnum] :count which count of mods to show per page. Valid values are: 1-500. Default: 30 (required)
	# @return [Array] an array containing the results found.
	# @raise [ArgumentError] if "page" is not an Integer
	# @raise [ArgumentError] if "page" is 0
	# @raise [ArgumentError] if "orderby" is not "name", "updated" or "created"
	# @raise [ArgumentError] if "order" is not "asc" or "desc"
	# @raise [ArgumentError] if "count" is 0 or greater than 500
	# @raise [ArgumentError] if not all parameters are present
	def self.browse(browse_params = {})
		page = browse_params[:page] || browse_params["page"]
		orderby = browse_params[:orderby] || browse_params["orderby"]
		order = browse_params[:order] || browse_params["order"]
		count = browse_params[:count] || browse_params["count"]
		
		if page
			raise ArgumentError, "page must be an Integer" unless page.is_a?(Integer)
			raise ArgumentError, "invalid value specified for page. valid values: 1-???" unless page > 0
		end
		
		raise ArgumentError, "orderby must be a String" unless orderby.is_a?(String)
		raise ArgumentError, "order must be a String" unless order.is_a?(String)
		raise ArgumentError, "count must be a Fixnum" unless count.is_a?(Fixnum)
		
		raise ArgumentError, "invalid value specified for orderby. valid values: name, updated, created" unless orderby.downcase == "name" || orderby.downcase == "updated" || orderby.downcase == "created"
		raise ArgumentError, "invalid value specified for order. valid values are: asc, desc" unless order.downcase == "asc" || order.downcase == "desc"
		raise ArgumentError, "invalid value specified for count. valid values are: 1-500" unless count > 0 && count < 500
		
		browse_url = "https://kerbalstuff.com/api/browse"
		
		# Check if the page argument is included. If it isn't, then we don't need it to browse the mods.
		if page && orderby && order && count
			browse_url = "#{browse_url}?page=#{page}&orderby=#{orderby}&order=#{order}&count=#{count}"
			mod_json = get_json(browse_url)
			
			arr = []
			
			results = mod_json['result']
			results.each do |mod|
				arr.push(Mod.new(mod))
			end
			
			return arr
		elsif orderby && order && count
			browse_url = "#{browse_url}?orderby=#{orderby}&order=#{order}&count=#{count}"
			mod_json = get_json(browse_url)
			
			arr = []
			
			results = mod_json['result']
			results.each do |mod|
				arr.push(Mod.new(mod))
			end
			
			return arr
		else
			raise ArgumentError, "Missing browse parameter(s)" unless orderby && order && count
		end
	end
	
	# Gets the newest mods on the site
	#
	# @param browse_params [Hash] browses the website with the specified parameters
	# @option browse_params [Integer] :page which page of results to retrieve. Valid values: 1-??? (optional)
	# @return [Array] an array containing the newest mods on the site.
	# @raise [ArgumentError] if "page" is not an Integer
	# @raise [ArgumentError] if "page" is 0
	def self.browse_recent(browse_params = {})
		page = browse_params[:page] || browse_params["page"]
		
		raise ArgumentError, "page must be an Integer" unless page.is_a?(Integer)
		raise ArgumentError, "invalid value specified for page. valid values: 1-???" unless page > 0
		
		browse_url = "https://kerbalstuff.com/api/browse/new"
		
		if page
			browse_url = "#{browse_url}?page=#{page.to_s}"
			mod_json = get_json(browse_url)
			arr = []
			
			mod_json.each do |mod|
				arr.push(Mod.new(mod))
			end
			
			return arr
		else
			mod_json = get_json(browse_url)
			arr = []
			
			mod_json.each do |mod|
				arr.push(Mod.new(mod))
			end
			
			return arr
		end
	end
	
	# Gets the latest featured mods on the site
	#
	# @param browse_params [Hash] browses the website with the specified parameters
	# @option browse_params [Integer] :page which page of results to retrieve. Valid values: 1-??? (optional)
	# @return [Array] an array containing the newest mods on the site.
	# @raise [ArgumentError] if "page" is not an Integer
	# @raise [ArgumentError] if "page" is 0
	def self.browse_featured(browse_params = {})
		page = browse_params[:page] || browse_params["page"]
		
		raise ArgumentError, "page must be an Integer" unless page.is_a?(Integer)
		raise ArgumentError, "invalid value specified for page. valid values: 1-???" unless page > 0
		
		browse_url = "https://kerbalstuff.com/api/browse/featured"
		
		if page
			browse_url = "#{browse_url}?page=#{page}"
			mod_json = get_json(browse_url)
			arr = []
			
			mod_json.each do |mod|
				arr.push(Mod.new(mod))
			end
			
			return arr
		else
			mod_json = get_json(browse_url)
			arr = []

			mod_json.each do |mod|
				arr.push(Mod.new(mod))
			end
			
			return arr
		end
	end
	
	# Gets the most popular mods on the site
	#
	# @param browse_params [Hash] browses the website with the specified parameters
	# @option [Integer] :page which page of results to retrieve. Valid values: 1-??? (optional)
	# @return [Array] an array containing the newest mods on the site.
	# @raise [ArgumentError] if "page" is not an Integer
	# @raise [ArgumentError] if "page" is 0
	def self.browse_top(browse_params = {})
		page = browse_params[:page] || browse_params["page"]
		
		raise ArgumentError, "page must be an Integer" unless page.is_a?(Integer)
		raise ArgumentError, "invalid value specified for page. valid values: 1-???" unless page > 0
		
		browse_url = "https://kerbalstuff.com/api/browse/top"
		
		if page
			browse_url = "#{browse_url}?page=#{page}"
			mod_json = get_json(browse_url)
			arr = []
			
			mod_json.each do |mod|
				arr.push(Mod.new(mod))
			end
			
			return arr
		else
			mod_json = get_json(browse_url)
			arr = []

			mod_json.each do |mod|
				arr.push(Mod.new(mod))
			end
			
			return arr
		end
	end
	
	private :self.get_json, :self.get_https_response
	
end