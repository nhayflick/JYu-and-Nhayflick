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
require './secrets'
require 'uri'

CONSUMER = OAuth::Consumer.new(
  CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

class Status
  def initialize(user, text)
    @user = user
    @text = text
  end

end

class User
  attr_reader :id, :screen_name
  def initialize(screen_name)
    @screen_name
    @statuses = []
  end

  def statuses
    @statuses.each do |status|
      puts status.text
    end
  end
end

class EndUser < User
  @@access_token = nil

  def initialize
    @screen_name = get_screen_name
    #save_login("#{@screen_name}-login.txt")
    get_access_token
    @@current_user = self
  end

  def write_status
    status_string = gets.chomp
    if status_string.length < 140
      payload = tweet_translate(status_string)
      user_post_URL = Addressable::URI.new(
        :scheme => "https",
        :host => "api.twitter.com",
        :path => "1.1/statuses/update.json"
      ).to_s
      puts user_post_URL
      puts payload
      @@access_token.post(user_post_URL, payload)

    end
  end

  def tweet_translate(status_string)
    {:status => URI.escape(status_string)}
  end


  def get_screen_name
    puts "Please type in your twitter handle:"
    screen_name = gets.chomp
  end

  def get_access_token
    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url
    puts "Please go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)
    puts "Login, and type your verification code."
    oauth_verifier = gets.chomp
    @@access_token = request_token.get_access_token(
    :oauth_verifier => oauth_verifier)
  end

  def save_login(token_file)
    if File.exist?(token_file)
      File.open(token_file) { |f| YAML.load(f)}
    else
      @@access_token = get_access_token
      File.open(token_file, "w") { |f| YAML.dump(@@access_token,f) }

      @@access_token
    end
  end

  def user_timeline
    user_timeline_URL = Addressable::URI.new(
      :scheme => "https",
      :host => "api.twitter.com",
      :path => "1.1/statuses/user_timeline.json",
      :query_values => {"screen_name" => self.screen_name}
    ).to_s
    puts user_timeline_URL
    @@access_token.get(user_timeline_URL).body
  end

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

  def self.current_user
    @@current_user
  end
end

