class Table < ActiveRecord::Base
  belongs_to :tournament
  has_and_belongs_to_many :players,  join_table: 'seatings'
  has_many :seatings
  has_many :rounds

  validates_presence_of :tournament_id

  def active_players # Not an ARel
    seatings.where(:active => true).order("id ASC").map(&:player)
  end

  def start_play!
    self.playing = true
    self.save!

    next_round!
  end

  def next_round!
    raise "Not enough players to play!" if active_players.size <= 1
    self.rounds.create(player_order: player_order_for_new_round)
  end

  def current_round
    self.rounds.order("id DESC").first
  end

  # Players are always sitting in order of their ID. However,
  # the dealer rotates between rounds.
  def player_order_for_new_round
    # Current round is still the old round.
    active_player_ids = active_players.map(&:id)
    if current_round
      old_dealer_id = current_round.player_order.split(" ").first.to_i
      # First, try to find someone later in the order.
      dealer_id = active_player_ids.find { |x| x > old_dealer_id } || 
                # Fall back to the first player.
                active_player_ids.first
    else
      dealer_id = active_player_ids.first
    end

    # Yee
    active_player_ids.partition{ |x| x >= dealer_id }.flatten.join(" ")
  end
end
