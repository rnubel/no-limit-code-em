require 'ruby-poker'

class SmartBot < Bot

  def initialize(opts)
    @name = opts[:name] || ("SmartBot" + rand(100000).to_s)
    @delay = opts[:delay].to_f || 1
    @logger = opts[:logger] || Logger.new(STDOUT)
  end

  def decide_action!(s)
    hand = PokerHand.new(s["hand"])
    pot = s["players_at_table"].map { |p| p["current_bet"] }.sum
    case s["betting_phase"]
    when 'deal'
      @discards = ""
      case hand.rank
      when "Two pair", "Three of a kind", "Straight", "Flush", "Full house", "Four of a kind", "Straight Flush", "Royal Flush"
        @discards = ""
        action(:action_name => "bet", :amount => s["maximum_bet"])
      else
        if hand.rank == "Pair"
          @discards = hand.score[1].split(/ /)[2..4].join(" ")
          if s["minimum_bet"] <= pot
            action(:action_name => "bet", :amount => s["minimum_bet"])
          else
            action(:action_name => "fold")
          end
        else hand.rank == "Highest Card"
          if hand.score[1][0] != 'A' && !possible_straight?(hand) && !possible_flush?(hand) && !possible_straight_flush?(hand)
            action(:action_name => "fold")
          elsif possible_straight_flush?(hand) && s["minimum_bet"] <= 0.32 * pot
            action(:action_name => "bet", :amount => (0.32 * pot).to_i)
          elsif possible_straight?(hand) && s["minimum_bet"] <= 0.17 * pot
            action(:action_name => "bet", :amount => (0.17 * pot).to_i)
          elsif possible_flush?(hand) && s["minimum_bet"] <= 0.19 * pot
            action(:action_name => "bet", :amount => (0.19 * pot).to_i)
          elsif s["minimum_bet"] <= 0.1 * pot
            @discards = hand.score[1].split(/ /)[2..4].join(" ")
            action(:action_name => "bet", :amount => (0.1 * pot).to_i)
          else
            action(:action_name => "fold")
          end
        end
      end
    when 'draw'
      action(:action_name => "replace", :cards => @discards)
    when 'post_draw'
      case hand.rank
      when "Two pair", "Three of a kind", "Straight", "Flush", "Full house", "Four of a kind", "Straight Flush", "Royal Flush"
        action(:action_name => "bet", :amount => s["maximum_bet"])
      when "Pair"
        if s["minimum_bet"] <= pot
          action(:action_name => "bet", :amount => s["minimum_bet"])
        else
          action(:action_name => "fold")
        end
      else
        action(:action_name => "fold")
      end
    end
  end

  private
  
  def possible_straight_flush?(hand)
    xform_hand = hand.send(:delta_transform).split(/ /).map { |c| [c[0], c[2]] }
    if xform_hand.select { |c| c[0] == "1" }.size == 3
      tmp_ary = []
      xform_hand.each_with_index do |c, i|
        if c[0] == "1" || (xform_hand[i+1] && xform_hand[i+1][0] == "1")
          tmp_ary << c
        end
      end
      if tmp_ary.map { |c| c[1] }.uniq.size == 1
        return true
      end
    end
    return false
  end

  def possible_straight?(hand)
    hand.send(:delta_transform).split(/ /).map { |c| c[0] }.select { |c| c == "1" }.size == 3
  end

  def possible_flush?(hand)
    hand.by_suit.each_cons(4) do |run|
      if run.map(&:suit).uniq.size == 1
        return true
      end
    end
    return false
  end
end
