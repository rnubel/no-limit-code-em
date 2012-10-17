require 'httparty'

class Bot
  include HTTParty
  base_uri ENV['host'] || 'localhost:3000'

  attr_accessor :key

  def register(params)
    response = self.class.post("/api/players", :body => params)
    puts response

    raise "Registration failed" unless response["key"]

    self.key = response["key"]
  end

  def status
    response = self.class.get("/api/players/#{key}")
    puts response
  end

  def action(params)
    self.class.post("/api/players/#{key}/action", :body => params)
  end
end

namespace :bot do
  task :run do
    b = Bot.new
    b.register(:name => "Player1")

    while true
      puts b.status

      b.action(:action_name => "bet", :amount => 0)
      b.action(:action_name => "replace", :cards => "")

      sleep 1
    end
  end
end
