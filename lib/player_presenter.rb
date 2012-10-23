class PlayerPresenter
  attr_accessor :player

  def initialize(player)
    @player = player
  end
  
  def to_json
    {
      :name => @player.name,
      :initial_stack => stack,
      :your_turn => @player.my_turn?,
      :current_bet => @player.current_bet,
      :minimum_bet => minimum_bet,
      :maximum_bet => stack,
      :hand => hand,
      :betting_phase => betting_phase,
      :players_at_table => players_at_table,
      :table_id => table && table.id,
      :round_id => round && round.id,
      :round_history => round_history,
      :lost_at => @player.lost_at
    }
  end

  def round_history
    @player.round_players.includes(:round).order("id DESC").limit(10).collect { |rp|
      {
        :round_id => rp.round_id,
        :table_id => rp.round.table_id,
        :stack_change => rp.stack_change
      }
    }
  end

  def table
    @table ||= @player.table
  end

  def round
    @round ||= @player.round
  end

  def stack
    @stack ||= player.stack # Not changing while this object is alive
  end

  def hand
    @player.current_player_state(:hand) || ""
  end

  def betting_phase
    @player.current_game_state(:round)
  end

  def minimum_bet
    [stack, 
     @player.current_game_state(:minimum_bet) || 0].min
  end

  def players_at_table
    if table
      table.players.ordered.collect do |p|
        { :player_name => p.name,
          :initial_stack => p.stack,
          :current_bet => p.current_bet,
          # These are the *actual* actions as seen by
          # PokerTable for this player. It may be different
          # from what they entered, but is more accurate.
          :actions => p.actions_in_current_round
                       .map {|a| action_json(a) }
        }
      end
    else
      [] # No reason to mess with the format
    end
  end

  # Nested presenter... sort of.
  def action_json(action_log_item)
    action_log_item.except(:player_id)
  end
end
