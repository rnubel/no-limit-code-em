require 'spec_helper'

describe Round do
  subject { FactoryGirl.create(:round)  }

  before {
    3.times do 
      subject.players << FactoryGirl.create(:player)
    end

    subject.dealer = subject.players.second
  }

  describe "its deck" do
    it "should have 52 cards" do
      subject.deck.split(" ").size.should == 52
    end
  end

  describe "its ante" do
    it "is set" do
      subject.ante.should_not be_nil
    end
  end

  it "has an ordered list of players" do
    subject.ordered_players.should == [
      subject.players.second, subject.players.last, subject.players.first
    ]
  end

  it "records actions" do
    subject.record_action! player: subject.players.first,
                           action: "bet",
                           amount: 100

    subject.should have(1).action
  end

  describe "its state" do
    describe "initial state" do
      it "knows the player list" do
        subject.initial_state.players.should == [
          { id: subject.players[1].id, stack: 0 },
          { id: subject.players[2].id, stack: 0 },
          { id: subject.players[0].id, stack: 0 },
        ]
      end
    end

    it "simulates all actions via PokerTable" do
      PokerTable.any_instance.expects(:simulate!)

      subject.state
    end
  end
end
