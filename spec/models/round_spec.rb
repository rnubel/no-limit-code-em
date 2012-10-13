require 'spec_helper'

describe Round do
  subject { FactoryGirl.create(:round) }
  
  describe "its deck" do
    it "should have 52 cards" do
      subject.deck.split(" ").size.should == 52
    end
  end

  describe "its ante" do
    it "is set by a call to table.tournament.current_ante on creation" do
      Tournament.any_instance.expects(:current_ante).returns(100)

      subject.ante.should == 100
    end
  end

  it "has an ordered list of players" do
    3.times do 
      subject.players << FactoryGirl.create(:player)
    end

    subject.dealer = subject.players.second

    subject.ordered_players.should == [
      subject.players.second, subject.players.last, subject.players.first
    ]
  end

  it "records actions" do
    pending
  end

  describe "its current status" do
    it "simulates all actions via PokerTable" do
      pending
    end
  end
end
