class Player < ActiveRecord::Base
  has_and_belongs_to_many :tournaments, join_table: 'registrations'
  has_and_belongs_to_many :tables,      join_table: 'seatings'
  has_many :seatings

  validates_presence_of :name, :key

  def self.standing
    joins("LEFT JOIN seatings ON seatings.player_id = players.id AND seatings.active = true").where("seatings.id IS NULL")
  end
    
end
