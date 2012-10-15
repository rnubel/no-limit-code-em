require 'spec_helper'

describe Player do
  it "should be able to register in a tournament" do
    t = Tournament.create
    p = FactoryGirl.create :player, :tournament => t

    p.tournament.should == t
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

  context "when seated" do
    subject { FactoryGirl.create(:player) }

    before { subject.tables << FactoryGirl.create(:table) }

    specify { subject.table.should_not be_nil }
  end

  context "when being unseated" do
    subject { FactoryGirl.create(:player) }
    
    before { subject.tables << FactoryGirl.create(:table) 
             subject.unseat! }

    specify { subject.table.should be_nil }
  end

  describe "stack" do
    let!(:player) {
      FactoryGirl.create(:player, :registered)
    }

    let(:table) { player.tables.create(:tournament => player.tournament) }

    it "starts out at an initial value" do
      player.stack.should == player.initial_stack
    end

    context "after one round" do
      before {
        table.rounds.create(:playing => false, :players => [player])
        rp = player.reload.round_players.first
        rp.stack_change = 10; rp.save!
      }

      it "reflects the changed stack" do
        player.stack.should == 110
      end
    end

    context "after two rounds" do
      before {
        table.rounds.create(:playing => false, :players => [player])
        rp = player.reload.round_players.first
        rp.stack_change = 10; rp.save!
        table.rounds.create(:playing => false, :players => [player])
        rp = player.reload.round_players.last
        rp.stack_change = -30; rp.save!
      }

      it "reflects the changed stack" do
        player.stack.should == 80
      end

      it "should be able to go back in time" do
        player.stack(player.rounds.first).should == 110
      end
    end
  end
end
