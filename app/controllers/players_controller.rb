class PlayersController < ApplicationController

  def show
    player_id = params[:id]
    @player = Player.find(player_id)

    # Preload all player names.
    @players = @player.tournament.players.select([:id, :name, :initial_stack]).reduce({}) { |h, p| h[p.id] = p;h }
  end

end
