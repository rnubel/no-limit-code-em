require 'rubygems'
require 'httpclient'
require 'httpclient/include_client'
require 'json'
extend HTTPClient::IncludeClient

base_uri = ENV['host'] || 'http://localhost:3000'

keys = ["fc2455f8-1879-4ad4-8012-1f337c2869f2", "728f53dd-a5dc-4582-8864-be37576b9592"]

keys.each do |key|

  response = HTTPClient.new.get("#{base_uri}/sandbox/players/#{key}")
  json = JSON.parse(response.body)
  puts "CURRENT GAME STATE:"
  puts json
  
  if json["betting_phase"] == "deal"
    params = {:action_name => "bet", :amount => 25}
  else
    params = {:action_name => "replace", :cards => "7H 8C 2D"}
  end
  puts
  puts "NEW GAME STATE:"
  response = HTTPClient.new.post("#{base_uri}/sandbox/players/#{key}/action", :body => params)
  json = JSON.parse(response.body)
  puts json
  puts
  
end
