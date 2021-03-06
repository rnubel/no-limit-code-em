require 'spec_helper'

describe Tournament do
  subject { Tournament.create game_type: 'draw_poker', open: true }

  it "is open or closed" do
    Tournament.create(game_type: 'draw_poker',  open: true  ).should be_open
    Tournament.create(game_type: 'hold_em',     open: false ).should_not be_open
  end

  it "starts out as not playing" do
    subject.should_not be_playing
  end

  it "allows players to register" do
    t = Tournament.create game_type: 'draw_poker'
    t.register_player!(FactoryGirl.create(:player))

    t.players.size.should == 1
  end

  context "small tournament" do

    before :each do
      Tournament.any_instance.stubs(:table_size).returns(4)

      5.times do
        subject.players << FactoryGirl.create(:player)
      end
    end

    context "when started" do
      before { subject.start! }

      it { should_not be_open }
      it { should be_playing }

      describe "table seating with 4 players per table" do
        it { should have(2).tables }
        
        it "seats players evenly" do
          subject.tables.ordered[0].should have(3).active_players
          subject.tables.ordered[1].should have(2).active_players
        end
      end
      
      it "starts play at each table" do
        subject.tables.each { |t|
          t.should be_playing
          t.should have(1).round
        }
      end
    end

    context "when redistributing" do
      before { subject.start!
               subject.players.first.lose!
               subject.tables.each do |t| t.next_round! end
               subject.balance_tables! }

      it "should have just one playing table" do
        subject.tables.playing.reload.count.should == 1
      end
    end

    context "when timing out players" do
      before { subject.start! }

      it "times out the player if enough time has passed" do
        fp = subject.rounds.first.ordered_players.first
        t  = subject.rounds.first.created_at + 8.seconds
        Time.stubs(:now).returns(t) # dammit, newrelic

        subject.timeout_players!

        fp.reload.actions.first.action.should == "fold"
      end
    end

    describe "#current_ante" do
      it "starts off at the base value" do
        subject.current_ante.should == 10
      end

      context "when 2 players remain" do
        before {
          subject.players[0..2].each do |player|
            player.lost_at = DateTime.now
            player.save!
          end
        }

        it "returns the ante as 50" do
          subject.current_ante.should == 50
        end
      end
    end
  end

  describe "larger tournament" do
    before {
      11.times do
        subject.players << FactoryGirl.create(:player, :tournament => subject)
      end

      subject.start!
    }

    context "when balancing tables" do
      it "fills up gaps and then creates more tables" do
        5.times do
          subject.players << FactoryGirl.create(:player, :tournament => subject)
        end

        subject.balance_tables!

        subject.tables.map { |t| t.players.count }.should =~ [6, 6, 4]
      end

      it "does not assign players to empty tables" do
        subject.tables.order("id ASC").first.players.each do |p|
          p.lose!
        end

        5.times do
          subject.players << FactoryGirl.create(:player, :tournament => subject)
        end

        subject.tables.order("id ASC").first.should have(0).active_players
      end
    end
  end
end
