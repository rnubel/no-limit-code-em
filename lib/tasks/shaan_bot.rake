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
    when "Straight" || "Flush" || "Full house" || "Four of a kind" || "Straight Flush" || "Royal Flush"
      action = "bet"
      amount = max_bet
    else
      action = "fold" if min_bet == stack
    end
    return action, amount
  end
  
  def decide_replacement(hand)
    pair_types = ["Pair", "Three of a kind", "Four of a kind"]
    perfect_hands = ["Straight", "Flush", "Full house", "Royal Flush", "Straight Flush"]
    if pair_types.include?(PokerHand.new(hand).rank)
      cards = hand.map {|c| c[0]}
      pair = cards.group_by { |e| e }.values.max_by { |values| values.size }.first
      replace_indices = cards.each_with_index.map do |c, i|
        if c != pair then i end
      end
      replace_indices.delete(nil)
      replacement_cards = replace_indices.map {|i| hand[i]}
    elsif PokerHand.new(hand).rank == "Two pair"
      cards = hand.map {|c| c[0]}
      fifth_card = cards.group_by { |e| e }.values { |values| values.size }.sort!{|a,b| b.length <=> a.length}.last[0]
      index = cards.index(fifth_card)
      replacement_cards = hand[index]
    elsif perfect_hands.include?(PokerHand.new(hand).rank)
      replacement_cards = []
    elsif PokerHand.new(hand).rank == "Highest Card"
      replacement_cards = PokerHand.new(hand).by_face.to_a[2..4]
    end
    return replacement_cards
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
      cards = decide_replacement(s["hand"])
      action(:action_name => "replace", :cards => cards)
      #action(:action_name => "replace", :cards => s["hand"].shuffle.first(rand(4)).join(" "))
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
