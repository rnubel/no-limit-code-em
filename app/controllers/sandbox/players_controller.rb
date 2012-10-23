module Sandbox
  class PlayersController < ApplicationController
    include ApiErrors

    # GET /sandbox/players/:key
    def show
      if params[:id].length >= 32
        json = '{"name":"Bill9","initial_stack":250,"your_turn":true,"current_bet":20,"minimum_bet":25,"maximum_bet":250,"hand":["6D","5C","AS","5H","9H"],"betting_phase":"deal","players_at_table":[{"player_name":"Bill8","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"Bill9","initial_stack":250,"current_bet":20,"actions":[{"action":"ante","amount":20}]}],"table_id":88,"round_id":105,"round_history":[{"round_id":105,"table_id":88,"stack_change":null}],"lost_at":null}'
        render :json => JSON.parse(json)
      else
        render_not_found "Invalid key. Should look like #{SecureRandom.uuid}"
      end
    end

    # POST /sandbox/players/:key/action
    def action
      return render_bad_request "Amount must be a positive integer if passed" if 
        params[:amount] && (params[:amount].to_i < 0)

      @player = Player.find_by_key(params[:id])

      action_params = { :action => params[:action_name], 
                        :amount => params[:amount] && params[:amount].to_i, 
                        :cards =>  cards_value(params[:cards]) }
    end
    
    
  end
end