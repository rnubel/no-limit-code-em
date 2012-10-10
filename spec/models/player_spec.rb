require 'spec_helper'

describe Player do
  it "should be able to register in a tournament" do
    p = FactoryGirl.create :player
    t = Tournament.create
    
    Registration.create(player: p, tournament: t)

    p.tournaments.reload.first.should == t
  end
end
