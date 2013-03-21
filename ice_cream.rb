#Ask user for their address.
#Submit user address to geocoding API to get lat and long coords.
#Submit user coords to Places API and search for nearby ice cream.
#Present Ice cream list to user. Get user selection.
#Give user coord and selected ice cream coords to Directions API and get directions.
#clean directions using nokogiri and present to user.
require 'json'
require 'rest-client'

def ice_cream_finder
  puts "Enter your current address."
  address = gets.chomp
  address_query = address_to_request(address)
  response = RestClient.get(address_query)
  geo_hash = JSON.parse(response)
  coordinates = lat_long(geo_hash)
  puts coordinates
  get_places = get_nearby_ice_cream(coordinates)
  places_results = RestClient.get(get_places)
  places_hash = JSON.parse(places_results)
  display_shop_list(places_hash)
  true
end

def lat_long(geo_hash)
  lat = geo_hash["results"][0]["geometry"]["location"]["lat"]
  long = geo_hash["results"][0]["geometry"]["location"]["lng"]
  coordinates = "#{lat},#{long}"
end

def address_to_query(address)
  address.gsub!(/\s+/, '+').gsub!(/[.']/, '')
  address
end

def address_to_request(address)
  geocoding_URL_prefix =
    "http://maps.googleapis.com/maps/api/geocode/json?address="
  geocoding_URL_suffix = "&sensor=false"
  address_query = geocoding_URL_prefix + address_to_query(address) +
    geocoding_URL_suffix
end

def get_nearby_ice_cream(coordinates)
  places_URL_prefix =
    "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
  location = "location=#{coordinates}"
  radius = "radius=1000"
  keyword = "keyword=ice+cream"
  types = "types=food"
  sensor = "sensor=false"
  key = "key=AIzaSyCfWfZljyp0xNlxKm2Y46IVl6HRluzm4Vg"
  places_request =
    "#{places_URL_prefix}#{location}&#{radius}&#{keyword}&#{types}&#{sensor}&#{key}"
end

def display_shop_list(places_hash)
  shops_array = places_hash["results"]
  shops_array.each_with_index do |shop_hash, i|
    puts "#{i + 1}. #{shop_hash["name"]} Rating: #{shop_hash["rating"]}\n#{shop_hash["vicinity"]}"
  end
end