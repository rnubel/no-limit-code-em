module Sandbox
  class PlayersController < ApplicationController
    include ApiErrors

    # GET /sandbox/players/:key
    def show
      if params[:id] == "fc2455f8-1879-4ad4-8012-1f337c2869f2"
        json = '{"name":"George Laffel","initial_stack":250,"your_turn":true,"current_bet":20,"minimum_bet":25,"maximum_bet":250,"hand":["6D","5C","AS","5H","9H"],"betting_phase":"deal","players_at_table":[{"player_name":"Jesse Smith","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"Sally Pausin","initial_stack":250,"current_bet":20,"actions":[{"action":"ante","amount":20}]}],"table_id":88,"round_id":105,"round_history":[{"round_id":105,"table_id":88,"stack_change":null}],"lost_at":null}'
        render :json => JSON.parse(json)
      elsif params[:id] == "728f53dd-a5dc-4582-8864-be37576b9592"
        json = '{"name":"Victor Lee","initial_stack":250,"your_turn":true,"current_bet":25,"minimum_bet":25,"maximum_bet":250,"hand":["2C","7H","8C","3D","2D"],"betting_phase":"draw","players_at_table":[{"player_name":"Daniel Adams","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"James Fink","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]}],"table_id":92,"round_id":110,"round_history":[{"round_id":110,"table_id":92,"stack_change":null}],"lost_at":null}'
        render :json => JSON.parse(json)
      else
        render_not_found "Invalid key. Should look like #{SecureRandom.uuid}"
      end
    end

    # POST /sandbox/players/:key/action
    def action
      case params[:id]
      when "fc2455f8-1879-4ad4-8012-1f337c2869f2"
        json = '{"name":"George Laffel","initial_stack":250,"your_turn":true,"current_bet":20,"minimum_bet":25,"maximum_bet":250,"hand":["6D","5C","AS","5H","9H"],"betting_phase":"deal","players_at_table":[{"player_name":"Jesse Smith","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"Sally Pausin","initial_stack":250,"current_bet":20,"actions":[{"action":"ante","amount":20}]}],"table_id":88,"round_id":105,"round_history":[{"round_id":105,"table_id":88,"stack_change":null}],"lost_at":null}'
        return render_bad_request "Amount must be a positive integer" if params[:amount] && (params[:amount].to_i < 0)
      when "728f53dd-a5dc-4582-8864-be37576b9592"
        json = '{"name":"Victor Lee","initial_stack":250,"your_turn":true,"current_bet":25,"minimum_bet":25,"maximum_bet":250,"hand":["2C","7H","8C","3D","2D"],"betting_phase":"draw","players_at_table":[{"player_name":"Daniel Adams","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]},{"player_name":"James Fink","initial_stack":250,"current_bet":25,"actions":[{"action":"ante","amount":20},{"action":"bet","amount":25}]}],"table_id":92,"round_id":110,"round_history":[{"round_id":110,"table_id":92,"stack_change":null}],"lost_at":null}'
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
        changed_state = take_action(JSON.parse(json), action)
        render :json => changed_state
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
    
    def take_action(json, action)
      logger.debug "JSON: #{json}"
      case action[:action]
      when "bet"
        raised_amount = action[:amount] - json["current_bet"].to_i
        json["current_bet"] = action[:amount]
        json["initial_stack"] = (json["initial_stack"].to_i - raised_amount)
      when "replace"
        @deck = ["AC", "6H", "QD"]
        json["hand"] = json["hand"].to_a - action[:cards]
        (5 - json["hand"].size).times do
          json["hand"].to_a.push @deck.delete_at(0)
        end
      end
      json["your_turn"] = false
      return json
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