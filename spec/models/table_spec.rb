require 'spec_helper'

describe Table do
  describe "seating" do
    before { 
      @table = FactoryGirl.build :table
      @table.players << FactoryGirl.build(:player)
      @table.players << FactoryGirl.build(:player)
      @table.save
    }

    subject { @table }

    it { should have(2).active_players }

    context "when one player leaves" do
      before { seating = subject.seatings.first;
               seating.active = false; seating.save! }

      it { should have(1).active_player }
    end
  end

  context "when starting play" do
    subject { FactoryGirl.create :table }
    before { 2.times { subject.players << FactoryGirl.create(:player) }}
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

  context "when changing rounds" do
    subject { FactoryGirl.create :table }
    before { 2.times { subject.players << FactoryGirl.create(:player) }}
    before { subject.start_play! }
    before { subject.next_round! }

    it "sets the old round to not be playing" do
      subject.rounds.first.should_not be_playing
    end
  end

  context "when rotating dealer order" do
    let(:subject) { FactoryGirl.create :table }
    before :each do
      2.times { subject.players << FactoryGirl.create(:player) }
      @p1 = subject.players.first
      @p2 = subject.players.last
      @p3 = FactoryGirl.create :player

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
      subject.current_round.ordered_players.should == [@p2, @p3, @p1]

      subject.players.first.unseat!

      subject.next_round!
      subject.current_round.ordered_players.should == [@p3, @p2]
    end
  end
end
