require 'bot'
require 'ruby-poker'

class ShaanBot < Bot
  def decide_action(hand, min_bet, max_bet, stack, current_bet)
    case PokerHand.new(hand).rank
    when "Highest Card"
      if current_bet == min_bet
        action = "bet"
        amount = min_bet
      else
        action = "fold"
      end
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
      action, amount = decide_action(s["hand"], s["minimum_bet"], s["maximum_bet"], s["initial_stack"] - s["current_bet"], s["current_bet"])
      
      if action == "fold"
        action(:action_name => "fold")
      else 
        action(:action_name => "bet", :amount => amount)
      end
  
    else
      action(:action_name => "replace", :cards => s["hand"].shuffle.first(rand(4)).join(" "))
    end
  end
end

namespace :shaan_bot do
  task :run do
    (ENV['num'] || 1).to_i.times.collect do |i|
      Thread.new do
        b = ShaanBot.new(
          :name => (name = Faker::Name.name),
          :delay => ENV['delay'] || 0.2,
          :logger => Logger.new("tmp/bot.#{i}.#{name}.log")
        ).run!
      end
    end.map(&:join)
  end
end
