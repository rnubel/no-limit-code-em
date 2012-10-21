require 'httparty'

class Bot
  include HTTParty
  base_uri ENV['host'] || 'localhost:3000'

  attr_accessor :key, :logger

  def initialize(opts)
    @name = opts[:name]
    @delay = opts[:delay] || 1
    @logger = opts[:logger] || Logger.new(STDOUT)
  end

  def register(params)
    response = self.class.post("/api/players", :body => params)
    puts response

    raise "Registration failed" unless response["key"]

    self.key = response["key"]
  end

  def status
    response = self.class.get("/api/players/#{key}")
  end

  def action(params)
    logger.info "[#{@name}] Decided on action: #{params.inspect}"
    self.class.post("/api/players/#{key}/action", :body => params)
  end

  def run!
    register(:name => @name)

    while true
      s = status
      logger.info "[#{@name}] Getting status... #{s['your_turn']}, #{s['betting_phase']}"

      if s["your_turn"]
        if s["betting_phase"] == 'deal' || s["betting_phase"] == 'post_draw'
          n = rand(100)
          if n < 30
            action(:action_name => "fold")
          else
            if n < 80 # Call
              action(:action_name => "bet", :amount => s["minimum_bet"])
            elsif n < 95 # Raise small
              action(:action_name => "bet", :amount => s["minimum_bet"] + rand(1..20))
            else # All-in baby
              action(:action_name => "bet", :amount => s["maximum_bet"])
            end
          end
        else
          action(:action_name => "replace", :cards => s["hand"].shuffle.first(rand(4)).join(" "))
        end
      end

      sleep @delay
    end
  end
end

namespace :bot do
  task :run do
    (ENV['num'] || 1).to_i.times.collect do
      Thread.new do
        b = Bot.new(
          :name => Faker::Name.name,
          :delay => ENV['delay'] || 0.2
        ).run!
      end
    end.map(&:join)
  end
end
