class Seating < ActiveRecord::Base
  belongs_to :player
  belongs_to :table

  def self.active
    where(:active => true)
  end
end
