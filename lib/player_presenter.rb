class PlayerPresenter
  attr_accessor :player

  def initialize(player)
    @player = player
  end
  
  def to_json
    {
      :name             => @player.name,
      :your_turn        => @player.my_turn?,
      :initial_stack    => stack,
      :stack            => current_stack,
      :current_bet      => @player.current_bet,
      :call_amount      => call_amount,
      :hand             => hand,
      :betting_phase    => betting_phase,
      :players_at_table => players_at_table,
      :total_players_remaining => total_players_remaining,
      :table_id         => table && table.id,
      :round_id         => round && round.id,
      :round_history    => round_history,
      :lost_at          => @player.lost_at,
      :community_cards  => round && round.community_cards
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

  def current_stack
    @player.stack - (@player.current_bet || 0)
  end

  def state
    @state ||= @player.current_game_state
  end

  def hand
    @player.current_player_state(:hand) || []
  end

  def betting_phase
   state && state.round
  end

  def minimum_bet
    [stack, 
     @player.current_game_state(:minimum_bet) || 0].min
  end

  def call_amount
    minimum_bet - (@player.current_bet || 0)
  end

  def player_property(id, property)
    @player_hash ||= state && state.players.reduce({}) { |h, p|
      h[p[:id]] = p; h
    }

    @player_hash && @player_hash[id] && @player_hash[id][property]
  end

  def players_at_table
    if table
      table.active_players.collect { |p|
        next unless player_property(p.id, :id)
        initial_stack = player_property(p.id, :initial_stack)
        current_bet = player_property(p.id, :current_bet) || 0
        # These are the *actual* actions as seen by
        # PokerTable for this player. It may be different
        # from what they entered, but is more accurate.
        actions = state.log.select { |a| a[:player_id] == p.id }
                           .map    { |a| a.except(:player_id) }

        { :player_name => p.name,
          :initial_stack => initial_stack,
          :current_bet => current_bet,
          :stack => initial_stack - current_bet,
          :folded => actions.any? { |a| a[:action] == "fold" },
          :actions => actions 
        }
      }.compact
    else
      [] # No reason to mess with the format
    end
  end

  def total_players_remaining
    @player.tournament.players.playing.count
  end

  # Nested presenter... sort of.
  def action_json(action_log_item)
    action_log_item.except(:player_id)
  end
end
