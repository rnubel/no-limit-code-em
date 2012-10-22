require 'httpclient'
require 'httpclient/include_client'

class Bot
  extend HTTPClient::IncludeClient

  include_http_client(ENV['host'] || 'localhost:3000')

  def base_uri
    ENV['host'] || 'localhost:3000'
  end

  attr_accessor :key, :logger

  def initialize(opts)
    @name = opts[:name]
    @delay = opts[:delay].to_f || 1
    @logger = opts[:logger] || Logger.new(STDOUT)
  end

  def register(params)
    response = http_client.post("#{base_uri}/api/players", :body => params)
    json = JSON.parse(response.body)

    raise "Registration failed" unless json["key"]

    self.key = json["key"]
  end

  def status
    response = http_client.get("#{base_uri}/api/players/#{key}")
    json = JSON.parse(response.body)
  end

  def action(params)
    logger.info "[#{@name}] Decided on action: #{params.inspect}"
    http_client.post("#{base_uri}/api/players/#{key}/action", :body => params)
  end

  def decide_action!(s)
    logger.info s.inspect
    if s["betting_phase"] == 'deal' || s["betting_phase"] == 'post_draw'
      n = rand(100)
      if n < 30
        action(:action_name => "fold")
      else
        if n < 80 # Call
          action(:action_name => "bet", :amount => s["minimum_bet"])
        elsif n < 95 # Raise small
          action(:action_name => "bet", :amount => [s["minimum_bet"] + rand(1..20), s["maximum_bet"]].min)
        else # All-in baby
          action(:action_name => "bet", :amount => s["maximum_bet"])
        end
      end
    else
      action(:action_name => "replace", :cards => s["hand"].shuffle.first(rand(4)).join(" "))
    end
  end

  def run!
    register(:name => @name)

    while true
      s = status
      logger.info "[#{@name}] Getting status... #{s['your_turn']}, #{s['betting_phase']}"
      break if s["lost_at"]

      if s["your_turn"]
        decide_action!(s)
      end

      sleep @delay
    end
  end
end

namespace :bot do
  task :run do
    (ENV['num'] || 1).to_i.times.collect do |i|
      Thread.new do
        b = Bot.new(
          :name => (name = Faker::Name.name),
          :delay => ENV['delay'] || 0.2,
          :logger => Logger.new("tmp/bot.#{i}.#{name}.log")
        ).run!
      end
    end.map(&:join)
  end
end
