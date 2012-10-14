class Player < ActiveRecord::Base
  has_many :registrations
  has_many :seatings
  has_many :round_players
  has_many :tournaments, :through => :registrations
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

  def stack(tournament, round=nil)
    raise "Cannot get stack without tournament reference." unless tournament
    q = self.round_players.joins(:table)
            .where(:tables => 
                { :tournament_id => tournament.id })
    if round
      q = q.where("round_id <= #{round.id}")
    end

    initial_stack = tournament.registrations
                    .where(:player_id => self.id)
                    .first.purse

    initial_stack + q.sum(:stack_change)
  end

  # Unseat this player from their current table.
  def unseat!
    raise "Player is not seated!" unless current_seating
    s = current_seating
    s.active = false;
    s.save!
  end
end
