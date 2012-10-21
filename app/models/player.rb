class Player < ActiveRecord::Base
  has_many :seatings
  has_many :round_players
  belongs_to :tournament
  has_many :tables,      :through => :seatings
  has_many :rounds,      :through => :round_players

  after_initialize :buy_in
  attr_accessible :initial_stack, :latest_stack, :name, :key

  validates_presence_of :name, :key

  scope :ordered, order("id ASC")
  scope :playing, where("lost_at IS NULL")

  def self.standing
    joins("LEFT JOIN seatings ON seatings.player_id = players.id AND seatings.active").where("seatings.id IS NULL")
  end

  def actions
    Action.where(:player_id => self.id)
  end

  def buy_in
    self.initial_stack ||= AppConfig.tournament.initial_stack
  end

  def current_seating
    return @current_seating if @current_seating # Clear this when a player leaves their table.

    active_seatings = seatings.active
    # Assert a sanity check.
    raise "Player is seated at more than one table!" if active_seatings.size > 1

    @current_seating = active_seatings.first
  end
  
  def table
    (s = current_seating) && s.table
  end

  def stack(round=nil)
    raise "Cannot get stack -- player not registered" unless tournament_id
   
    q = self.round_players
    key = ""
    if round
      q = q.where("round_id < #{round.id}")
      key = "round-id/#{round.id}"
    else
      key = "round-count/#{rounds.over.count}"
    end

    Rails.cache.fetch("players/#{id}/stack/#{key}") do
      (initial_stack || 0) + q.sum(:stack_change)
    end
  end

  # Unseat this player from their current table.
  def unseat!
    raise "Player is not seated!" unless current_seating
    s = current_seating
    s.active = false;
    s.save!

    @current_seating = nil
  end

  def lose!
    unseat! if current_seating
    self.lost_at = Time.now  
    self.save!
  end

  # Have this player attempt to take the given action.
  def take_action!(action_params)
    table.take_action! action_params.merge(:player => self) 
  end

  def valid_action?(action_params)
    table.valid_action? action_params.merge(:player => self) 
  end

  def round
    rounds.last
  end

  def current_game_state(property = nil)
    s = (r = self.round) && r.state
    property ? s && s.send(property) : s
  end

  def current_player_state(property = nil)
    ps = (s = current_game_state) && s.players.find { |p| p[:id] == self.id }
    ps && (property ? ps[property] : ps)
  end
  
  def current_stack
    current_player_state(:stack)
  end

  def current_bet
    current_player_state(:current_bet)
  end

  def hand
    current_player_state(:hand)
  end

  def actions_in_current_round
    current_game_state.log.select { |l| l[:player_id] == self.id }
  end

  def my_turn?
    !!(table && table.playing && table.current_player == self)
  end

  def idle_time
    return 0 unless r = round
    last_action_in_round = Action.where(:round_id => r.id).order("id ASC").last 
    Time.now - (last_action_in_round && last_action_in_round.created_at || r.created_at)
  end
end
