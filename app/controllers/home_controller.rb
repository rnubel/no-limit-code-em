class HomeController < ApplicationController
  respond_to :json

  def index
    #@scoreboard = Status.get_leaderboard
    #@tables = Status.get_players_at_tables
    redirect_to '/pages/docs/index.html' unless Tournament.last.playing?
  end

  def scoreboard
    redirect_to '/pages/docs/index.html' unless Tournament.last.playing?
  end

  def update
    #@scoreboard = Status.get_leaderboard
    #@tables = Status.get_players_at_tables
    #@registration = true if Status.first.registration
  end
end
