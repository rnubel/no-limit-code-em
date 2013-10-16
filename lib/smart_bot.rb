require 'ruby-poker'

class SmartBot < Bot

  def initialize(opts)
    @name = opts[:name] || ("Pete's Mom" + rand(100000).to_s)
    @delay = opts[:delay].to_f || 1
    @logger = opts[:logger] || Logger.new(STDOUT)
  end

  def decide_action!(s)
    hand = PokerHand.new(s["hand"])
    pot = s["players_at_table"].map { |p| p["current_bet"] }.sum
    if s["call_amount"] > 0
      potodds = pot.to_f / (pot.to_f + (s["call_amount"].to_f))
    else
      potodds = pot.to_f / (pot.to_f + s["current_bet"].to_f)
    end
    case s["betting_phase"]
    when 'deal'
      @discards = ""
      case hand.rank
      when "Two pair"
        @discards = hand.score[1].split(/ /).last
        #logger.info "hand: #{hand.to_s}, discard: #{@discards}, bet: #{s["maximum_bet"]}"
        action(:action_name => "bet", :amount => s["stack"])
      when "Three of a kind"
        @discards = hand.score[1].split(/ /)[3..4]
        #logger.info "hand: #{hand.to_s}, discard: #{@discards}, bet: #{s["maximum_bet"]}"
        action(:action_name => "bet", :amount => s["stack"])
      when "Straight", "Flush", "Full house", "Four of a kind", "Straight Flush", "Royal Flush"
        @discards = ""
        #logger.info "hand: #{hand.to_s}, discard: #{@discards}, bet: #{s["maximum_bet"]}"
        action(:action_name => "bet", :amount => s["stack"])
      else
        if hand.rank == "Pair"
          @discards = hand.score[1].split(/ /)[2..4].join(" ")
          if potodds >= 0.5
            #logger.info "hand: #{hand.to_s}, discard: #{@discards}, bet: #{s["minimum_bet"]}, pot: #{pot}"
            action(:action_name => "bet", :amount => s["call_amount"])
          else
            #logger.info "hand: #{hand.to_s}, discard: #{@discards}, pot: #{pot}, minbet: #{s["minimum_bet"]}, fold"
            action(:action_name => "fold")
          end
        else hand.rank == "Highest Card"
          if hand.score[1][0] != 'A' && !possible_straight?(hand) && !possible_flush?(hand) && !possible_straight_flush?(hand)
            #logger.info "hand: #{hand.to_s}, high card, no ace, no possibles, fold"
            action(:action_name => "fold")
          elsif possible_straight_flush?(hand) && potodds >= 0.32
            @discards = hand.by_suit.to_a.group_by { |c| c.suit }.select { |k,v| v.size == 1 }.values[0][0]
            #logger.info "possible straight flush - hand: #{hand.to_s}, discard: #{@discards}, bet: #{[s["maximum_bet"], (0.32 * pot).to_i].min}"
            action(:action_name => "bet", :amount => [s["stack"], (0.32 * pot).to_i].min)
          elsif possible_straight?(hand) && potodds >= 0.17
            if hand.by_face.to_a[0].face - hand.by_face.to_a[1].face == 1
              @discards = hand.by_face.to_a.last
            else
              @discards = hand.by_face.to_a.first
            end
            #logger.info "possible straight - hand: #{hand.to_s}, discard: #{@discards}, bet: #{[s["maximum_bet"], (0.17 * pot).to_i].min}"
            action(:action_name => "bet", :amount => [s["stack"], (0.17 * pot).to_i].min)
          elsif possible_flush?(hand) && potodds >= 0.19
            @discards = hand.by_suit.to_a.group_by { |c| c.suit }.select { |k,v| v.size == 1 }.values[0][0]
            #logger.info "possible flush - hand: #{hand.to_s}, discard: #{@discards}, bet: #{[s["maximum_bet"], (0.19 * pot).to_i].min}"
            action(:action_name => "bet", :amount => [s["stack"], (0.19 * pot).to_i].min)
          elsif potodds >= 0.1
            @discards = hand.score[1].split(/ /)[2..4].join(" ")
            #logger.info "ace high - hand: #{hand.to_s}, discard: #{@discards}, pot: #{pot}, minbet: #{s["minimum_bet"]}, bet: #{s["minimum_bet"]}"
            action(:action_name => "bet", :amount => s["call_amount"])
          else
            #logger.info "ace high - hand: #{hand.to_s}, discard: #{@discards}, pot: #{pot}, minbet: #{s["minimum_bet"]}, fold"
            action(:action_name => "fold")
          end
        end
      end
    when 'draw'
      action(:action_name => "replace", :cards => @discards)
    when 'post_draw'
      case hand.rank
      when "Two pair", "Three of a kind", "Straight", "Flush", "Full house", "Four of a kind", "Straight Flush", "Royal Flush"
        #logger.info "hand: #{hand.to_s}, go all in"
        action(:action_name => "bet", :amount => s["stack"])
      when "Pair"
        if potodds >= 0.3
          action(:action_name => "bet", :amount => s["call_amount"])
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
