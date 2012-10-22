require 'httpclient'
require 'ruby-poker'
class Bot
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
    response = HTTPClient.new.post("#{base_uri}/api/players", :body => params)
    json = JSON.parse(response.body)

    raise "Registration failed" unless json["key"]

    self.key = json["key"]
  end

  def status
    response = HTTPClient.new.get("#{base_uri}/api/players/#{key}")
    json = JSON.parse(response.body)
  end

  def action(params)
    logger.info "[#{@name}] Decided on action: #{params.inspect}"
    HTTPClient.new.post("#{base_uri}/api/players/#{key}/action", :body => params)
  end
  
  def decide_action(hand, min_bet, max_bet, stack)
    case PokerHand.new(hand).rank
    when "Pair"
      action = "bet"
      amount = [min_bet + 5, max_bet].min
    when "Two pair"
      action = "bet"
      amount = [min_bet + 10, max_bet].min
    when "Three of a kind"
      action = "bet"
      amount = [min_bet + 20, max_bet].min
    when "Straight"
      action = "bet"
      amount = max_bet
    when "Flush"
      action = "bet"
      amount = max_bet
    when "Full house"
      action = "bet"
      amount = max_bet
    when "Four of a kind"
      action = "bet"
      amount = max_bet
    else
      action = "fold" if min_bet == stack
    end
    return action, amount
  end

  def take_action!(s)
    if s["betting_phase"] == 'deal' || s["betting_phase"] == 'post_draw'
      action, amount = decide_action(s["hand"], s["minimum_bet"], s["maximum_bet"], s["initial_stack"] - s["current_bet"])
      
      if action == "fold"
        action(:action_name => "fold")
      else 
        action(:action_name => "bet", :amount => amount)
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
        take_action!(s)
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
