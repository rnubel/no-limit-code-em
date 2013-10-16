require 'spec_helper'

describe Player do
  it "should be able to register in a tournament" do
    t = FactoryGirl.create :tournament
    p = FactoryGirl.create :player    , :tournament => t

    p.tournament.should == t
  end

  it "should require a name and a key" do
    p = Player.create
    p.valid?.should be_false
  end

  it "is created with a set stack by default" do
    p = Player.create
    p.initial_stack.should == AppConfig.tournament.initial_stack
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
    subject { FactoryGirl.create(:player, :registered) }

    before { FactoryGirl.create(:table, 
              :tournament => subject.tournament,
              :players => [subject,
                           FactoryGirl.create(:player, :registered, 
                                              tournament: subject.tournament)
                          ]) }

    specify { subject.table.should_not be_nil }

    context "when a round hasn't been started" do
      it "can't take actions" do
        subject.valid_action?(action:"fold").should be_false
      end
    end

    context "when a round has started" do
      before { subject.tables.first.start_play! }

      it "can take actions" do
        subject.take_action!(action:"fold")
      end

      it "can check if an action can be taken" do
        subject.valid_action?(action:"fold").should be_true
      end

      it "can check its current game state" do
        subject.current_game_state.should be_a DrawPokerTable
      end
      
      its(:current_player_state) {
        should have_key(:hand)
      }
    end
  end

  context "when being unseated" do
    subject { FactoryGirl.create(:player) }
    
    before { subject.tables << FactoryGirl.create(:table) 
             subject.unseat! }

    specify { subject.table.should be_nil }
    specify { subject.current_game_state.should be_nil }
  end

  describe "stack" do
    let!(:player) {
      FactoryGirl.create(:player, :registered, :initial_stack => 100)
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
        player.stack(player.rounds.first).should == 100
        player.stack(player.rounds.last).should == 110
      end
    end
  end

  describe "#my_turn?" do
    subject { FactoryGirl.create(:player, :registered) }

    it "is never the player's turn when they don't have a table" do
      subject.my_turn?.should == false
    end

    it "is the player's turn when the table says it is" do
      subject.tables.create!(:tournament => subject.tournament)
      Table.any_instance.expects(:current_player).returns(subject)
      Table.any_instance.expects(:playing).returns(true)

      subject.should be_my_turn
    end
  end
end
