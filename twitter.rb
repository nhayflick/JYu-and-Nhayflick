# Build a command line Twitter API.
#
# 1. Post a status
# 2. Get your timeline
# 3. Get statuses for users
# 4. Direct message other users
#Hint: you will eventually need to set your app to ask to both read and post on your users' behalf. This is a key benefit of OAuth: a gradation of permission levels.
#You will want to use the OAuth gem.

require 'addressable/uri'
require 'rest-client'
require 'oauth'
#require 'login.rb'
require 'launchy'
require 'yaml'
require 'secrets.rb'

class Twitter


  def get_user_id(screen_name)
    show_user_URL = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/users/show.json",
      :query_values => {:screen_name => screen_name}
    ).to_s
    puts show_user_URL
    show_user_results = RestClient.get(show_user_URL)
    user_ID = JSON.parse(show_user_results)["id_str"]
  end

end

class User
attr_reader :id, :screen_name

end

class Status
  attr_reader :user


end
