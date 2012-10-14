class Tournament < ActiveRecord::Base
  has_many :registrations
  has_many :players, 
           :through => :registrations
  has_many :tables

  def start!
    self.open = false
    self.save! # Disallow anyone coming in before we start seating.
               # It is possible that someone will still get missed,
               # but reseating should pick them up.

    create_initial_seatings!
    
    tables.each { |t| t.start_play! }
  end

  def register_player!(player, purse)
    registrations.create!(player: player,
                          purse: purse,
                          current_stack: purse)
  end

  # Create new tables for any players not seated.
  def create_initial_seatings!
    players.standing.each_in_tables(table_size) do |players_at_table|
      self.tables.create( players: players_at_table )
    end
  end

  # Merge mergeable tables.
  def balance_tables!
  end

  def current_ante
    20
  end

  def table_size
    6 # TODO: Figgy
  end
end
