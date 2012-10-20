class Tournament < ActiveRecord::Base
  has_many :registrations
  has_many :players
  has_many :tables

  scope :open, where(:open => true)
  scope :playing, where(:playing => true)

  def start!
    self.open = false
    self.playing = true
    self.save! # Disallow anyone coming in before we start seating.
               # It is possible that someone will still get missed,
               # but reseating should pick them up.

    #hand_out_chips!
    create_seatings!
    
    tables.each { |t| t.start_play! }
  end

  def end!
    self.playing = false
    self.save!
  end

  def register_player!(player)
    self.players << player
    player.save!
  end

  def hand_out_chips!
    self.players.each do |p|
      p.initial_stack = AppConfig.tournament.initial_stack
      p.save!
    end
  end

  # Create new tables for any players not seated.
  def create_seatings!
    players.playing.standing.each_in_tables(table_size) do |players_at_table|
      self.tables.create( players: players_at_table.sort_by(&:id) )   # Sort for testing purposes only.
    end
  end

  # Reseat any players who stood up because they expected to be reseated.
  def balance_tables!
    open_tables = self.tables.playing
    players.playing.standing.each do |player|
      if new_table = open_tables.find { |t| t.open_seats >= 1 }
        new_table.players << player
      end
    end

    # Reseat leftover players.
    create_seatings!
  end

  def current_ante
    20
  end

  def table_size
    AppConfig.tournament.table_size
  end
end
