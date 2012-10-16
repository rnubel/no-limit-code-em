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

    # GET /api/players/:key
    def show
      if @player = Player.find_by_key(params[:id])
        render :json => status(@player)
      else
        render_not_found "No player registered with that key."
      end
    end

    # POST /api/players/:key/action
    def action
      @player = Player.find_by_key(params[:id])

      action_params = { :action => params[:action_name], 
                        :amount => params[:amount], 
                        :cards => params[:cards] }

      if not @player
        render_not_found "No player registered with that key."
      elsif @player.valid_action? action_params
        @player.take_action! action_params

        render :json => status(@player)
      else
        render_unprocessable_entity "That action (#{action_params.inspect}) is not valid."
      end
    end

    private
    # TODO: move to presenter
    def status(player)
      {
        :name => player.name,
        :stack => player.stack,
        :your_turn => player.my_turn?
      }
    end
  end
end
