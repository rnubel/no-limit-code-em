class Player < ActiveRecord::Base
  has_and_belongs_to_many :tournaments, join_table: 'registrations'
  has_and_belongs_to_many :tables,      join_table: 'seatings'
  has_many :seatings

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

  # Unseat this player from their current table.
  def unseat!
    raise "Player is not seated!" unless current_seating
    s = current_seating
    s.active = false;
    s.save!
  end
end
