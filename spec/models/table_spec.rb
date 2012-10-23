require 'spec_helper'

describe Table do
  subject { 
    table = FactoryGirl.create :table
  }

  before {
    2.times do
      subject.players <<  FactoryGirl.create(:player, 
                              :tournament => subject.tournament,
                              :initial_stack => 1000)
    end
    subject.save!
  }

  describe "seating" do
    it { should have(2).active_players }

    context "when one player leaves" do
      before { seating = subject.seatings.first;
               seating.active = false; seating.save! }

      it { should have(1).active_player }
    end
  end

  context "when starting play" do
    before { subject.start_play! }

    it { should be_playing }

    it { should have(1).rounds }
  
    it "knows its current round" do
      subject.current_round.should == subject.rounds.last
    end

    it "sets the round as playing" do
      subject.current_round.should be_playing
    end

    it "tells the round the dealer" do
      subject.current_round.dealer.should == subject.players.first
    end
    
    it "tells the round the players in the round" do
      subject.current_round.players.should == subject.players
    end
  end

  context "when taking actions from players" do
    let(:action)  {
      { player: subject.players.first,
        action: "bet",
        amount: 100 }
    }
    before { subject.start_play! }

    it "knows the current player" do
      subject.current_player.should == subject.players.first 
    end

    it "can check if an action is valid" do
      Round.any_instance.expects(:valid_action?) 
      subject.valid_action? action
    end

    it "should delegate to current_round" do
      Round.any_instance.expects(:take_action!) 
      subject.take_action! action
    end

    it "moves to the next round if that action ended the round" do
      Round.any_instance.expects(:take_action!) 
      Round.any_instance.stubs(:over?).returns(true)
      subject.take_action! action
      subject.should have(2).rounds  
    end
  end

  context "when changing rounds" do
    before { subject.start_play! }
            
            
    context "when play can continue" do
      before { subject.next_round! }

      it "sets the old round to not be playing" do
        subject.rounds.ordered.first.should_not be_playing
      end
    end

    context "when play should stop" do
      let(:loser) { subject.players.order("id ASC").first }
      before { Round.any_instance.stubs(:losers).returns([loser]) }
      before { subject.next_round! }
      
      it "unseats all players" do
        subject.active_players.size.should == 0
      end

      it "makes the loser lose" do
        loser.reload.lost_at.should_not be_nil
      end

      it "should not open a new round" do
        subject.should have(1).round
      end
    end
  end

  context "when rotating dealer order" do
    before :each do
      @p1 = subject.players.order("id ASC").first
      @p2 = subject.players.order("id ASC").last
      @p3 = FactoryGirl.create :player, :tournament => subject.tournament, :initial_stack => 1000

      subject.start_play!
    end

    it "rotates dealer when no players leave or join" do
      subject.current_round.ordered_players.should == [@p1, @p2]
      subject.next_round!
      subject.current_round.ordered_players.should == [@p2, @p1]
      subject.next_round!
      subject.current_round.ordered_players.should == [@p1, @p2]
    end

    it "handles when a player joins or leaves" do
      subject.current_round.ordered_players.should == [@p1, @p2]
      subject.players << @p3

      subject.next_round!
      subject.current_round.dealer.should == @p2
      subject.current_round.ordered_players.should == [@p2, @p3, @p1]

      subject.players.first.unseat!

      subject.next_round!
      subject.current_round.ordered_players.should == [@p3, @p2]
    end
  end
end
