class WelcomeController < ApplicationController
  def index
  	
  end
  def search
  	require 'open-uri'
  	require 'net/http'
  	require 'nokogiri'
  	require 'json'

  	@username = params[:q]
  	@via_pinners = Array.new
  	prefix = "https://www.pinterest.com/pin/"

  	@request = JSON.load(open("https://api.pinterest.com/v3/pidgets/users/" + @username + "/pins/"))

  	pins = @request['data']['pins']

  	pins.each_with_index do |pin, index|
  		puts index+1
  		parse_url = prefix + pin['id']

  		uri = URI.parse(parse_url)
  		http = Net::HTTP.new(uri.host, uri.port)
  		http.use_ssl = true
  		http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  		tries ||= 5
  		begin
  			@data = http.get(uri.request_uri)
  		rescue
  			tries -= 1
  		  if tries > 0
  		    retry
  		  else
  		  	puts "F**k"
  		 	end
  		end
  		@doc = Nokogiri::HTML(@data.body)
  		@script = @doc.xpath("//script").to_s
  		
  		start = @script.index('via_pinner')+27
  		via_pinner = ''
  		i = start
  		while @script[i] != '"'
  			via_pinner += @script[i]
  			i += 1
  		end
  		@via_pinners.push(via_pinner)

  	end
  	
  end
end