class Table < ActiveRecord::Base
  belongs_to :tournament
  has_and_belongs_to_many :players,  join_table: 'seatings'
  has_many :seatings

  validates_presence_of :tournament_id

  def active_players # Not an ARel
    seatings.where(:active => true).map(&:player)
  end
end
