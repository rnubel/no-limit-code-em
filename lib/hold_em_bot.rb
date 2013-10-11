class HoldEmBot < Bot
  def decide_action!(s)
    logger.info "[#{@name}] (#{Time.now}) #{s.inspect}"
    if %w(deal flop turn river).include(s["betting_phase"])
      n = rand(100)
      if n < 50
        action(:action_name => "fold")
      else
        if n < 80 || s["stack"] <= s["call_amount"] # Call
          action(:action_name => "call")
        elsif n < 95 # Raise small
          action(:action_name => "raise", :amount => rand(1..20) )
        else # All-in baby
          action(:action_name => "raise", :amount => s["stack"] - s["call_amount"])
        end
      end
    end
  end
end
