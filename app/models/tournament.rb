class Tournament < ActiveRecord::Base
  has_and_belongs_to_many :players, :join_table => 'registrations'
  
  has_many :tables

  def start!
    self.open = false

    create_initial_seatings!

    self.save!
  end

  # Create new tables for any players not seated.
  def create_initial_seatings!
    Player.standing.each_in_tables(table_size) do |players_at_table|
      self.tables.create( players: players_at_table )
    end
  end

  # Merge mergeable tables.
  def balance_tables!
  end

  def table_size
    6 # TODO: Figgy
  end
end
