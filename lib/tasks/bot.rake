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
      puts (s = b.status)

      if s[:your_turn]
        if s[:betting_phase] == 'deal' || s[:betting_phase] == 'draw'
          b.action(:action_name => "bet", :amount => s[:minimum_bet])
        else
          b.action(:action_name => "replace", :cards => "")
        end
      end

      sleep 1
    end
  end
end
