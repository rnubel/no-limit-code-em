class PlayersController < ApplicationController

  def show
    player_id = params[:id]
    @player = Player.find(player_id)
    render 'players/show', :locals => {:player => @player}
  end

end
