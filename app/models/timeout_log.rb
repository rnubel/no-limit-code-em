class TimeoutLog < ActiveRecord::Base
  belongs_to :player
  belongs_to :round

  def dump
    puts "=======================  Actual Actions  ============================"
    self.round.actions.order("id ASC") do |a|
      puts a.inspect
    end

    puts "- - - - - - - - - - - - Requested Actions - - - - - - - - - - - - - -"

    RequestLog.where(:round_id => self.round_id).order("id ASC") do |r|
      puts r.inspect
    end
    puts "====================================================================="
  end
end
