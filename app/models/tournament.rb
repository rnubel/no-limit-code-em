class Tournament < ActiveRecord::Base
  has_and_belongs_to_many :players, :join_table => 'registrations'
  
  has_many :tables

end
