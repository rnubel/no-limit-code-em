require 'spec_helper'

describe PlayerPresenter do
  let(:player){ FactoryGirl.create(:player, :registered) }
  subject { PlayerPresenter.new(player) }

  describe("#to_json") {
    let(:player){ FactoryGirl.create(:player, :registered) }

    it "has the needed keys" do
      subject.to_json.keys.should =~ [:name, :initial_stack, :your_turn, :players_at_table, :total_players_remaining, :hand, :betting_phase, :table_id, :round_id, :round_history, :call_amount, :current_bet, :stack, :lost_at, :community_cards]
    end
  }

  describe "#hand" do
    it "presents a nil hand as an array" do
      subject.hand.should == []
    end

    it "handles actual cards" do
      player.stubs(:current_player_state).with(:hand).returns("AS AS AS AS AS")
      subject.hand.should == "AS AS AS AS AS"
    end
  end

  describe "#call_amount" do
    context "when no bets have been placed" do
      its(:call_amount) { should == 0 }
    end
    
    context "when a bet has been placed for 10" do
      before {
        player.stubs(:current_bet).returns(5)
        subject.stubs(:minimum_bet).returns(15)
      }

      its(:call_amount) { should == 10 }
    end
  end

  describe "#round_history" do

    before { player.round_players.create(:round => FactoryGirl.create(:round), :stack_change => 10)}

    it "shows round history" do
      subject.round_history.should == [{
        :round_id => player.round_players.first.round_id,
        :table_id => player.round_players.first.round.table_id,
        :stack_change => 10
      }]
    end
  end

  describe "#players_at_table" do
    subject { PlayerPresenter.new(player) }
    let(:player){ FactoryGirl.create(:player, :registered) }

    context "when player has no table" do
      it "is empty" do
        subject.players_at_table.should == []
      end
    end

    context "when player is at a table" do
      let(:player){ FactoryGirl.create(:player, :registered) }
      let(:player2) { FactoryGirl.create(:player, :registered,
                        :tournament => player.tournament ) }

      before {
        @table = FactoryGirl.create(:table, :tournament => player.tournament) 
        @table.players = [player, player2]
        @table.save!
        @table.start_play!
      }

      let(:antes) { [{:action => "ante", :amount => @table.current_round.ante}]}

      it "has basic stats" do
        subject.players_at_table
          .should == [ { :player_name => player.name, 
                         :initial_stack => player.stack,
                         :current_bet => @table.current_round.ante,
                         :folded => false,
                         :stack => player.stack - @table.current_round.ante,
                         :actions => antes},
                       { :player_name => player2.name, 
                         :initial_stack => player2.stack,
                         :current_bet => @table.current_round.ante,
                         :folded => false,
                         :stack => player2.stack - @table.current_round.ante,
                         :actions => antes}
                     ]
      end

      it "knows the latest bet" do
        player.take_action! action: "bet", amount: "30"

        subject.players_at_table
          .should == [ { :player_name => player.name, 
                         :initial_stack => player.stack,
                         :current_bet => @table.current_round.ante + 30,
                         :folded => false,
                         :stack => player.stack - @table.current_round.ante - 30,
                         :actions => antes + [{:action => "bet", :amount => 30}]},
                       { :player_name => player2.name, 
                         :initial_stack => player2.stack,
                         :current_bet => @table.current_round.ante,
                         :folded => false,
                         :stack => player2.stack - @table.current_round.ante,
                         :actions => antes}
                     ]
      end

      it "ignores players not in the round" do
        player.table.players << FactoryGirl.create(:player)

        subject.should have(2).players_at_table
      end
    end
  end

  describe "bet variables" do
    let(:player){ FactoryGirl.create(:player, :registered) }
    let(:player2) { FactoryGirl.create(:player, :registered,
                      :tournament => player.tournament ) }

    before {
      @table = FactoryGirl.create(:table, :tournament => player.tournament) 
      @table.players = [player, player2]
      @table.save!
      @table.start_play!
    }

    it "knows the current bet" do
      subject.to_json[:current_bet].should == @table.current_round.ante      
    end

    it "knows the call amount" do
      subject.to_json[:call_amount].should == 0
      player.take_action! action: "bet", amount: 1
      player2.take_action! action: "bet", amount: 1
      subject.to_json[:call_amount].should == 1
    end

    it "knows the player's stack" do
      subject.to_json[:stack].should == player.initial_stack - @table.current_round.ante
    end
  end
end
