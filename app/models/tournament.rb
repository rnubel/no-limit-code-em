class Tournament < ActiveRecord::Base
  has_many :registrations
  has_many :players
  has_many :tables
  has_many :rounds, :through => :tables

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
    new_tables = []
    players.playing.standing.each_in_tables(table_size) do |players_at_table|
      new_tables.push self.tables.create( players: players_at_table.sort_by(&:id) )   # Sort for testing purposes only.
    end

    new_tables.map &:start_play!
  end

  # Reseat any players who stood up because they expected to be reseated.
  def balance_tables!
    open_tables = self.tables.playing
    players.playing.standing.each do |player|
      if new_table = open_tables.find { |t| t.open_seats.between?(1, table_size - 1) }
        new_table.players << player
      end
    end

    # Reseat leftover players.
    create_seatings!
  end
  
  # Fold any players who have been inactive on their turn for at least AppConfig.tournament.timeout seconds.
  def timeout_players!(timeout = AppConfig.tournament.timeout)
    self.tables.playing.each do |table|
      if player = table.current_player
        if player.idle_time > timeout
          puts "!! Timing out #{player.id} for taking #{player.idle_time} seconds to act!"
          begin
            TimeoutLog.create(:player => player, :round => table.current_round)
            player.take_action!(:action => "fold")
          rescue
            puts "Not valid anymore."
          end
        end
      end
    end
  end

  def current_ante
    num_active_players = self.players.playing.count
    percent_active_players = num_active_players.to_f / self.players.count.to_f
    percent_inactive_players = 1.0 - percent_active_players
    avg_chipstack = (AppConfig.tournament.initial_stack * players.count) / num_active_players
    ante_percent = (0.08 / (1 + 100 * (2.71828 ** (-10 * percent_inactive_players)))) + 0.02
    ante = (ante_percent * avg_chipstack).to_i.round(-1)
  end

  def game_type
    :draw_poker
  end

  def table_size
    config.table_size
  end

  def config
    AppConfig.tournament
  end
end
