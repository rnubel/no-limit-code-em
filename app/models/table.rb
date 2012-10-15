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
    self.current_round && self.current_round.close!

    raise "Not enough players to play!" if active_players.size <= 1
    self.rounds.create( players: self.active_players, 
                        dealer: dealer_for_new_round,
                        playing: true)
  end

  def take_action!(action_params)
     self.current_round.record_action!(action_params)
  end

  def can_take_action?(action_params)
    (r = self.current_round) && r.valid_action?(action_params)
  end

  def current_round
    self.rounds.order("id DESC").first
  end

  def dealer_for_new_round
    if r = current_round
      active_players.find { |p| p.id > r.dealer_id } ||
       active_players.first
    else
      active_players.first
    end
  end
end
