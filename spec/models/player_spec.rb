require 'spec_helper'

describe Player do
  it "should be able to register in a tournament" do
    p = FactoryGirl.create :player
    t = Tournament.create
    
    Registration.create(player: p, tournament: t)

    p.tournaments.reload.first.should == t
  end

  it "should require a name and a key" do
    p = Player.create
    p.valid?.should be_false
  end

  describe "::standing" do
    it "should find players with no active seatings" do
      p1 = FactoryGirl.create(:player)
      p2 = FactoryGirl.create(:player)
      p3 = FactoryGirl.create(:player)

      p1.tables << FactoryGirl.create(:table)
      p2.tables << FactoryGirl.create(:table)

      s = p2.seatings.reload.last
      s.active = false; s.save!

      Player.standing.all.size.should == 2
    end
  end
end
