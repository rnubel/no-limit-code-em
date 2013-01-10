class TournamentPresenter
  attr_reader :tournament
  def initialize(tournament)
    @tournament = tournament
  end

  def scoreboard
    @scoreboard = tournament.players.each_with_index.collect { |p, i|
      {
        :name => p.name,
        :stack => p.stack,
        :lost_at => p.lost_at
      }
    }.sort_by { |p| [p[:stack], p[:lost_at]] }.reverse
  end

  def tables
    @tables = tournament.tables.playing.collect do |table|
      {
        :table_id => table.id,
        :players => table.active_players.collect { |p| {:player_id => p.id, 
                                                        :name => p.name, 
                                                        :initial_stack => p.current_player_state(:initial_stack),
                                                        :stack => p.current_player_state(:stack), 
                                                        :current_bet => p.current_player_state(:current_bet) }},
        :latest_winners => table.rounds
                                .ordered
                                .where(:playing => false)
                                .last(3)
                                .collect(&:winners) # At this point, list of hashes of winners
                                .map { |winners_hash| 
                                  winners_hash.collect { |(player, w) | 
                                    { :name => player.name, :winnings => w } 
                                  }
                                }
                                .flatten
      }
    end

    @tables.each do |t|
      t[:pot] = t[:players].sum {|h| h[:current_bet]}
    end
  end
end
