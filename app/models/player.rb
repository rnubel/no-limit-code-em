class Player < ActiveRecord::Base
  has_and_belongs_to_many :tournaments, join_table: 'registrations'
end
