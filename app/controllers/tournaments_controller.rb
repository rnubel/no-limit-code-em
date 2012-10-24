class TournamentsController < ApplicationController
  def index
    @tournaments = Tournament.where(:open => false, :playing => false).all
  end

  def show
    @tournament = Tournament.find(params[:id])
  end

  def scoreboard
    @tournament = Tournament.playing.last

    render :json => @tournament.players.each_with_index.collect { |p, i|
      {
        :name => p.name,
        :stack => p.stack
      }
    }.sort_by { |p| p[:stack] }.reverse
  end

  def tables
    @tournament = Tournament.playing.last

    table_list = @tournament.tables.playing.collect do |table|
      {
        :table_id => table.id,
        :players => table.active_players.collect { |p| {:player_id => p.id, 
                                                        :name => p.name, 
                                                        :initial_stack => p.current_player_state(:initial_stack),
                                                        :stack => p.current_player_state(:stack), 
                                                        :current_bet => p.current_player_state(:current_bet) }},
        :latest_winners => table.rounds.ordered.last(3).reject(&:playing).collect(&:winners).map { |h| h.map { |p, w| { :name => p.name, :winnings => w } }}
      }
    end

    render :json => table_list
  end
end
