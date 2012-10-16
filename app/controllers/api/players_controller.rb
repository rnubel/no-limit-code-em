module Api
  class PlayersController < ApplicationController
    include ApiErrors

    # POST /api/players
    #   name: string    
    def create
      tournament = Tournament.open.last

      if tournament
        @player = tournament.players.create name: params[:name],
                                            key: SecureRandom.uuid

        render :json => { :name =>  @player.name,
                          :key =>   @player.key   }
      else
        render_not_found "The tournament is currently closed."
      end
    end

    # GET /api/players/key
    def show

    end
  end
end
