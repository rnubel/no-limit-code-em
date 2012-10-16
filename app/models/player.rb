class Player < ActiveRecord::Base
  has_many :seatings
  has_many :round_players
  belongs_to :tournament
  has_many :tables,      :through => :seatings
  has_many :rounds,      :through => :round_players

  validates_presence_of :name, :key

  def self.standing
    joins("LEFT JOIN seatings ON seatings.player_id = players.id AND seatings.active = true").where("seatings.id IS NULL")
  end
 
  def current_seating
    active_seatings = seatings.active
    # Assert a sanity check.
    raise "Player is seated at more than one table!" if active_seatings.size > 1

    active_seatings.first
  end
  
  def table
    current_seating && current_seating.table
  end

  def stack(round=nil)
    raise "Cannot get stack -- player not registered" unless tournament
    q = self.round_players
    if round
      q = q.where("round_id <= #{round.id}")
    end

    initial_stack + q.sum(:stack_change)
  end

  # Unseat this player from their current table.
  def unseat!
    raise "Player is not seated!" unless current_seating
    s = current_seating
    s.active = false;
    s.save!
  end

  # Have this player attempt to take the given action.
  def take_action!(action_params)
    table.take_action! action_params.merge(:player => self) 
  end

  def valid_action?(action_params)
    table.valid_action? action_params.merge(:player => self) 
  end

  def current_game_state
    table && (r = table.current_round) && r.state
  end

  def current_player_state
    (s = current_game_state) && s.players.find { |p| p[:id] == self.id }    
  end

  def hand
    (p = current_player_state) && p[:hand]
  end

  def my_turn?
    !!(table && (table.current_player == self))
  end
end
