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
    if old_round = self.current_round
      old_round.close!

      # Kick out losers.
      old_round.losers.map(&:unseat!)
    end

    # If we can keep playing, do so.
    if active_players.size <= 1
      stop!
    else
      self.rounds.create( players: self.active_players, 
                          dealer: dealer_for_new_round,
                          playing: true)
    end
    
    # In some cases, the round will already be over. Check for that.
    if current_round.over?
      current_round.close!
      stop!
    end
  end

  def stop!
    self.playing = false
    self.save!
  end

  def take_action!(action_params)
     r = self.current_round
     r.take_action!(action_params)

     next_round! if r.over?
  end

  def valid_action?(action_params)
    (r = self.current_round) && r.valid_action?(action_params)
  end

  def current_round
    self.rounds.order("id DESC").first
  end

  def current_player
    r = self.current_round
    r && r.current_player 
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
