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

    it "tells the round the order of players" do
      subject.current_round.player_order.should == 
        subject.players.map(&:id).join(" ")
    end
  end

  context "when rotating dealer order" do
    let(:subject) { FactoryGirl.create :table }
    before :each do
      2.times { subject.players << FactoryGirl.create(:player) }
      @id1 = subject.players.first.id
      @id2 = subject.players.last.id
      subject.start_play!
    end

    it "rotates dealer when no players leave or join" do
      subject.current_round.player_order.should == "#{@id1} #{@id2}"
      subject.next_round!
      subject.current_round.player_order.should == "#{@id2} #{@id1}"
      subject.next_round!
      subject.current_round.player_order.should == "#{@id1} #{@id2}"
    end

    it "handles when a player joins or leaves" do
      subject.current_round.player_order.should == "#{@id1} #{@id2}"
      subject.players << FactoryGirl.create(:player)
      @id3 = subject.players.last.id

      subject.next_round!
      subject.current_round.player_order.should == "#{@id2} #{@id3} #{@id1}"

      subject.players.first.unseat!

      subject.next_round!
      subject.current_round.player_order.should == "#{@id3} #{@id2}"
    end
  end
end
