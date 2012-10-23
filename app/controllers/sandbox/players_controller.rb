module Sandbox
  class PlayersController < ApplicationController
    include ApiErrors

    # GET /sandbox/players/:key
    def show
      if params[:id] == "fc2455f8-1879-4ad4-8012-1f337c2869f2"
        json = '{"name":"Bill9","initial_stack":250,"your_turn":true,"current_bet":20,"minimum_bet":25,"maximum_bet":250,"hand":["6D","5C","AS","5H","9H"],"betting_phase":"deal","players_at_table":[{"player_name":"Bill8","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"Bill9","initial_stack":250,"current_bet":20,"actions":[{"action":"ante","amount":20}]}],"table_id":88,"round_id":105,"round_history":[{"round_id":105,"table_id":88,"stack_change":null}],"lost_at":null}'
        render :json => JSON.parse(json)
      elsif params[:id] == "728f53dd-a5dc-4582-8864-be37576b9592"
        json = '{"name":"Bill8","initial_stack":250,"your_turn":true,"current_bet":25,"minimum_bet":25,"maximum_bet":250,"hand":["2C","7H","8C","3D","2D"],"betting_phase":"draw","players_at_table":[{"player_name":"Bill8","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"Bill9","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]}],"table_id":92,"round_id":110,"round_history":[{"round_id":110,"table_id":92,"stack_change":null}],"lost_at":null}'
        render :json => JSON.parse(json)
      else
        render_not_found "Invalid key. Should look like #{SecureRandom.uuid}"
      end
    end

    # POST /sandbox/players/:key/action
    def action
      case params[:id]
      when "fc2455f8-1879-4ad4-8012-1f337c2869f2"
        json = '{"name":"Bill9","initial_stack":250,"your_turn":true,"current_bet":20,"minimum_bet":25,"maximum_bet":250,"hand":["6D","5C","AS","5H","9H"],"betting_phase":"deal","players_at_table":[{"player_name":"Bill8","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"Bill9","initial_stack":250,"current_bet":20,"actions":[{"action":"ante","amount":20}]}],"table_id":88,"round_id":105,"round_history":[{"round_id":105,"table_id":88,"stack_change":null}],"lost_at":null}'  
        return render_bad_request "Amount must be a positive integer" if params[:amount] && (params[:amount].to_i < 0)
      when "728f53dd-a5dc-4582-8864-be37576b9592"
        json = '{"name":"Bill8","initial_stack":250,"your_turn":true,"current_bet":25,"minimum_bet":25,"maximum_bet":250,"hand":["2C","7H","8C","3D","2D"],"betting_phase":"draw","players_at_table":[{"player_name":"Bill8","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"Bill9","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]}],"table_id":92,"round_id":110,"round_history":[{"round_id":110,"table_id":92,"stack_change":null}],"lost_at":null}'
        return render_bad_request "action_name must be set to replace instead of #{params[:action_name]}" if params[:action_name] != "replace"
        return render_bad_request 'cards must be an string of ' if !(cards_value(params[:cards]).is_a? Enumerable)
        logger.debug "Cards: #{params[:cards]}"
        logger.debug "Cards?: #{cards_value(params[:cards])}"
      else
        return render_not_found "Invalid key. Should look like #{SecureRandom.uuid}"
      end 
      
      action = { :action => params[:action_name], 
                 :amount => params[:amount] && params[:amount].to_i, 
                 :cards =>  cards_value(params[:cards]) }
      if valid_action?(JSON.parse(json), action)
        json = '{"action":"valid"}'
        render :json => JSON.parse(json)
      else
        json = '{"action":"invalid"}'
        render :json => JSON.parse(json)
      end
    end
    
    private
    
    def valid_action?(json, action)
      case action[:action]
          when "bet" # Absolute amount!            
            amount = action[:amount].to_i
            raised_amount = amount - (json["current_bet"] || 0)

            (amount >= json["minimum_bet"] || raised_amount == json["initial_stack"]) && raised_amount >= 0
          when "replace" # List of cards!
            return false unless action[:cards].is_a? Enumerable
            action[:cards].all? { |c|
              json["hand"].include?(c)
            } && action[:cards].size <= 3
          when "fold" # Should always be allowed, if it's their turn.
            true
          end
    end
    
    def cards_value(param)
      if param.is_a? String
        param.split(" ").map(&:upcase)
      else
        param && param.map(&:upcase)
      end
    end
    
    
  end
end