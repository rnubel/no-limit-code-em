require 'spec_helper'

describe Round do
  subject { FactoryGirl.create(:round)  }

  before {
    3.times do 
      p = FactoryGirl.create(:player, :registered, :tournament => subject.tournament)
      subject.players << p
      subject.save
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

  it "can validate actions" do
    subject.valid_action?(player: subject.players.second,
                          action: "fold").should be_true
  end

  it "records valid actions" do
    PokerTable.any_instance.expects(:valid_action?).returns true
    subject.take_action! player: subject.players.second,
                           action: "bet",
                           amount: 1

    subject.should have(1).action
  end

  it "records replacements" do
    subject.expects(:valid_action?).returns true
    subject.take_action!(player: subject.players.first, action: "replace", cards: ["AS", "5H"])
  end

  it "rejects invalid actions" do
    PokerTable.any_instance.expects(:valid_action?).returns false

    expect {
     subject.take_action!(player: subject.players.first,
                            action: "asdfasdff")}.to raise_error

    subject.should have(0).actions
  end

  describe "its state" do
    describe "initial state" do
      it "knows the player list" do
        subject.initial_state.should have(3).players
      end
    end

    it "simulates all actions via PokerTable" do
      PokerTable.any_instance.expects(:simulate!)

      subject.state
    end

    it "indicates when the round is not over" do
      subject.over?.should be_false
    end

    it "indicates when the round is over" do
      subject.ordered_players.first(2).each do |p|
        subject.take_action! player: p, action: "fold"
      end

      subject.should be_over
    end
    
    it "knows the current player" do
      subject.current_player.should == subject.players.second
    end

    it "knows the betting round" do
      subject.betting_round.should == 'deal'
    end
  end


  describe "when being closed" do
    it "should update its round_players with their stack change" do
      PokerTable.any_instance.expects(:stack_changes).returns({
        subject.players[0].id => -10,
        subject.players[1].id => -10,
        subject.players[2].id => 20,
      })

      subject.close!

      @p1 = subject.players.first
      subject.round_players.where(:player_id => @p1.id).first.
        stack_change.should == -10
    end
  end
end
