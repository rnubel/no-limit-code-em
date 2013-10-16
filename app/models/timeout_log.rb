class TimeoutLog < ActiveRecord::Base
  belongs_to :player
  belongs_to :round

  def dump
    self.reload

    puts "=======================  Actual Actions  ============================"
    puts self.round.actions.order("id ASC").map(&:inspect)

    puts "- - - - - - - - - - - - Requested Actions - - - - - - - - - - - - - -"

    puts RequestLog.where(:round_id => self.round_id).order("id ASC").map(&:inspect)
    puts "====================================================================="
  end
end
