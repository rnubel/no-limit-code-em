class HomeController < ApplicationController
  respond_to :json

  def index
    #@scoreboard = Status.get_leaderboard
    #@tables = Status.get_players_at_tables
    tournament = Tournament.playing.last

    @scoreboard = tournament.players.each_with_index.collect { |p, i|
      {
        :name => p.name,
        :stack => p.stack,
        :lost_at => p.lost_at
      }
    }.sort_by { |p| [p[:stack], p[:lost_at]] }.reverse

    @tables = tournament.tables.playing.collect do |table|
      {
        :table_id => table.id,
        :players => table.active_players.collect { |p| {:player_id => p.id, 
                                                        :name => p.name, 
                                                        :initial_stack => p.current_player_state(:initial_stack),
                                                        :stack => p.current_player_state(:stack), 
                                                        :current_bet => p.current_player_state(:current_bet) }},
        :latest_winners => table.rounds.ordered.last(3).reject(&:playing).collect(&:winners).map { |h| h.map { |p, w| { :name => p.name, :winnings => w } }}.flatten
      }
    end
  end

  def update
    #@scoreboard = Status.get_leaderboard
    #@tables = Status.get_players_at_tables
    #@registration = true if Status.first.registration
  end
end
