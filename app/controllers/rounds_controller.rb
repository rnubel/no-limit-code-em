class RoundsController < ApplicationController

  def show
    @round = Round.find(params[:id])
    @players = @round.tournament.players.select([:id, :name, :initial_stack]).reduce({}) { |h, p| h[p.id] = p;h } 
  end
end
