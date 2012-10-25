class TournamentsController < ApplicationController
  respond_to :json

  def index
    @tournaments = Tournament.where(:open => false, :playing => false).all
  end

  def show
    @tournament = Tournament.find(params[:id])
  end

  def refresh
    tournament = Tournament.playing.last
    
    if tournament
      p = TournamentPresenter.new(tournament)

      @scoreboard, @tables = p.scoreboard, p.tables
    end
  end
end
