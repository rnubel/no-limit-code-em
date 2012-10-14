class RoundPlayer < ActiveRecord::Base
  belongs_to :round
  belongs_to :player

  has_one :table, through: :round
end
