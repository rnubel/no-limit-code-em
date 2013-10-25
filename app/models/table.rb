class Table < ActiveRecord::Base
  belongs_to :tournament
  has_and_belongs_to_many :players,  join_table: 'seatings'
  has_many :seatings
  has_many :rounds

  validates_presence_of :tournament_id

  scope :playing, where(:playing => true)
  scope :ordered, order("id ASC")

  def active_players
    self.players.where("seatings.active")
  end

  def open_seats
    self.tournament.table_size - filled_seats
  end

  def filled_seats
    seatings.where(:active => true).count
  end

  def start_play!
    self.playing = true
    self.save!

    next_round!
  end

  def next_round!
    if old_round = current_round
      old_round.close!

      # Kick out losers.
      old_round.losers.map(&:lose!)
    end

    # If we can keep playing, do so.
    if active_players.size <= 1
      stop!
    elsif can_redistribute?
      stop!
    else
      self.rounds.create( players: self.active_players, 
                          dealer: dealer_for_new_round,
                          playing: true)
      @current_round = nil
    end
    
    # In some cases, the round will already be over. Check for that.
    if current_round && current_round.over?
      current_round.close!
      stop!
    end
  end

  def can_redistribute?
    slots_needed = filled_seats
    available_seats = self.tournament.tables.playing.where("id <> #{id}").all.sum(0, &:open_seats)

    slots_needed <= available_seats
  end

  def stop!
    self.active_players.each { |p| p.unseat! }
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
    @current_round ||= self.rounds.order("id DESC").first
  end

  def current_player
    r = self.current_round
    r && r.current_player 
  end

  def dealer_for_new_round
    if r = current_round
      if active_players.find { |p| p.id > r.dealer_id }
        old_dealer = r.dealer_id
        player_list = active_players.collect(&:id)
        i = player_list.index(old_dealer)
       return Player.find(player_list[i+1])
      else
       if active_players.first.id != r.dealer_id && active_players.count > 1
         return active_players.first
       else
         active_players.find(active_players.collect(&:id).min)
       end
      end
    else
      active_players.first
    end
  end
end
