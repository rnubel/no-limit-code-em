module Sandbox2
  class PlayersController < ApplicationController
    include ApiErrors

    # GET /sandbox/players/:id
    def show
      case params[id]
      when "initial-deal-key"
        return initial_deal_response.to_json
      when "replacement-stage-key"
        return replacement_stage_response.to_json
      when "final-bet-key"
        return final_bet_response.to_json
      else
        render_not_found "This is an invalid key. To view the different stages of the round, use initial-deal-key, replacement-stage-key, or final-bet-key to see current state."
      end
    end

    # POST /sandbox/players/:id/action
    def action
      case params[:id]
      when "initial-deal-key"
        initial_deal_processing(params).to_json
      when "replacement-stage-key"
        replacement_stage_processing(params).to_json
      when "final-bet-key"
        final_bet_processing(params).to_json
      else
        test
      end
    end
    
    private
    
    def cards_value(param)
      if param.is_a? String
        param.split(" ").map(&:upcase)
      else
        param && param.map(&:upcase)
      end
    end

    def initial_deal_response
      {
        :name => "Your Player",
        :initial_stack => 250,
        :your_turn => true,
        :current_bet => 20,
        :call_amount => 5,
        :hand => ["Ac", "10d", "9d", "Qd", "3h"],
        :betting_phase => "deal",
        :players_at_table => [
          {:player_name => "Other Player 1",
           :initial_stack => 220,
           :current_bet => 25,
           :folded => false,
           :stack => 195,
           :actions => [{ :action => "ante", :amount => 20 }, { :action => "raise", :action => "5" }]},
          {:player_name => "Other Player 2",
           :initial_stack => 100,
           :current_bet => 20,
           :folded => true,
           :stack => 80,
           :actions => [{ :action => "fold" }]},
          {:player_name => "Other Player 3",
           :initial_stack => 300,
           :current_bet => 20,
           :folded => false,
           :stack => 280,
           :actions => [{ :action => "ante", :amount => 20 }]}],
        :total_players_remaining => 14,
        :table_id => 2,
        :round_id => 3,
        :round_history => [ { :round_id => 2, :table_id => 2, :stack_change => -30 } ],
        :lost_at => nil
      }
    end

    def initial_deal_processing(opts)
      problems = []
      case opts[:action_name]
      when "bet", "raise"
        problems << "No amount was specified." unless opts[:amount]
        problems << "Amount must be a positive integer." unless opts[:amount] =~ /^[0-9]+$/
        problems << "Amount must not be more than your stack count." unless opts[:amount].to_i <= 230
        problems << "Amount must not be less than the call amount." unless opts[:amount].to_i >= 5
      when "call", "fold"
        # do nothing
      when "check"
        problems << "You may not check if you are required to match an opponent's raise."
      when "replace"
        problems << "This is a betting phase, cards can not be replaced."
      else
        problems << "You did not send a valid action. Try sending bet, raise, or fold."
      end
      initial_deal_response.merge({
        :sandbox_response => "You sent the following: #{ opts }",
        :validity => (problems.empty? ? "This is a valid response." : problems)
      })
    end

    def replacement_stage_response
      {
        :name => "Your Player",
        :initial_stack => 250,
        :your_turn => true,
        :current_bet => 25,
        :call_amount => 0,
        :hand => ["Ac", "10d", "9d", "Qd", "3h"],
        :betting_phase => "draw",
        :players_at_table => [
          {:player_name => "Other Player 1",
           :initial_stack => 220,
           :current_bet => 25,
           :folded => false,
           :stack => 195,
           :actions => [{ :action => "ante", :amount => 20 }, { :action => "bet", :amount => 5 }, { :action => "replace", :amount => 3 }]},
          {:player_name => "Other Player 2",
           :initial_stack => 100,
           :current_bet => 20,
           :folded => true,
           :stack => 80,
           :actions => [{ :action => "fold" }]},
          {:player_name => "Other Player 3",
           :initial_stack => 300,
           :current_bet => 25,
           :folded => false,
           :stack => 275,
           :actions => [{ :action => "ante", :amount => 20 }, { :action => "bet", :amount => 5 }]}],
        :total_players_remaining => 13,
        :table_id => 2,
        :round_id => 3,
        :round_history => [ { :round_id => 2, :table_id => 2, :stack_change => -30 } ],
        :lost_at => nil
      }
    end

    def replacement_stage_processing(opts)
      problems = []
      case opts[:action_name]
      when "bet", "raise", "call", "fold", "check"
        problems << "You may only replace cards during this round."
      when "replace"
        hand = ["AC", "10D", "9D", "QD", "3D"]
        cards = cards_value(opts[:cards])
        problems << "You can only replace a maximum of 3 cards." if cards.length > 3
        cards.each do |card|
          problems << "You do not have #{ card } in your hand." unless hand.include?(card)
        end
      when "fold"
        # do nothing
      else
        problems << "You did not send a valid action. Try sending replace or fold."
      end
      initial_deal_response.merge({
        :sandbox_response => "You sent the following: #{ opts }",
        :validity => (problems.empty? ? "This is a valid response." : problems)
      })
    end

    def final_bet_response
      {
        :name => "Your Player",
        :initial_stack => 250,
        :your_turn => true,
        :current_bet => 25,
        :call_amount => 20,
        :hand => ["Kd", "10d", "9d", "Qd", "3d"],
        :betting_phase => "post_draw",
        :players_at_table => [
          {:player_name => "Other Player 1",
           :initial_stack => 220,
           :current_bet => 45,
           :folded => false,
           :stack => 175,
           :actions => [{ :action => "ante", :amount => 20 }, { :action => "bet", :amount => 5 }, { :action => "replace", :amount => 3 }, { :action => "bet", :amount => 20 }]},
          {:player_name => "Other Player 2",
           :initial_stack => 100,
           :current_bet => 20,
           :folded => true,
           :stack => 80,
           :actions => [{ :action => "fold" }]},
          {:player_name => "Other Player 3",
           :initial_stack => 300,
           :current_bet => 25,
           :folded => false,
           :stack => 275,
           :actions => [{ :action => "ante", :amount => 20 }, { :action => "bet", :amount => 5 }, { :action => "replace", :amount => 1 }]}],
        :total_players_remaining => 13,
        :table_id => 2,
        :round_id => 3,
        :round_history => [ { :round_id => 2, :table_id => 2, :stack_change => -30 } ],
        :lost_at => nil
      }
    end

    def final_bet_processing(opts)
      problems = []
      case opts[:action_name]
      when "bet", "raise"
        problems << "No amount was specified." unless opts[:amount]
        problems << "Amount must be a positive integer." unless opts[:amount] =~ /^[0-9]+$/
        problems << "Amount must not be more than your stack count." unless opts[:amount].to_i <= 225
        problems << "Amount must not be less than the call amount." unless opts[:amount].to_i >= 20
      when "call", "fold"
        # do nothing
      when "check"
        problems << "You may not check if you are required to match an opponent's raise."
      when "replace"
        problems << "This is a betting phase, cards can not be replaced."
      else
        problems << "You did not send a valid action. Try sending bet, raise, or fold."
      end
      initial_deal_response.merge({
        :sandbox_response => "You sent the following: #{ opts }",
        :validity => (problems.empty? ? "This is a valid response." : problems)
      })
    end
  end
end
