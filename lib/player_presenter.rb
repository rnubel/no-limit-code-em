class PlayerPresenter
  attr_accessor :player

  def initialize(player)
    @player = player
  end
  
  def to_json
    {
      :name => @player.name,
      :stack => @player.current_stack,
      :your_turn => @player.my_turn?,
      :players_at_table => players_at_table
    }
  end

  def players_at_table
    if player.table
      player.table.players.ordered.collect do |p|
        { :player_name => p.name,
          :stack => p.current_stack,
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
