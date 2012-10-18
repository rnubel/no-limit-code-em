require 'spec_helper'

describe PlayerPresenter do
  subject { PlayerPresenter.new(player) }

  describe("#to_json") {
    let(:player){ FactoryGirl.create(:player, :registered) }

    it "has the needed keys" do
      subject.to_json.keys.should =~ [:name, :initial_stack, :your_turn, :players_at_table, :hand, :betting_phase, :table_id, :round_id, :round_history, :minimum_bet, :current_bet, :maximum_bet]
    end
  }

  describe "#hand" do
    subject { PlayerPresenter.new(player) }
    let(:player){ FactoryGirl.create(:player, :registered) }
    
    it "handles nils" do
      subject.hand.should == ""
    end

    it "handles actual cards" do
      player.stubs(:current_player_state).with(:hand).returns("AS AS AS AS AS")
      subject.hand.should == "AS AS AS AS AS"
    end
  end

  describe "#round_history" do
    subject { PlayerPresenter.new(player) }
    let(:player){ FactoryGirl.create(:player, :registered) }

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

      let(:antes) { [{:action => "ante", :amount => @table.current_round.ante }]}

      it "has basic stats" do
        subject.players_at_table
          .should == [ { :player_name => player.name, 
                         :initial_stack => player.current_stack,
                         :current_bet => @table.current_round.ante,
                         :actions => antes},
                       { :player_name => player2.name, 
                         :initial_stack => player2.current_stack,
                         :current_bet => @table.current_round.ante,
                         :actions => antes}
                     ]
      end

      it "knows the latest bet" do
        player.take_action! action: "bet", amount: "50"

        subject.players_at_table
          .should == [ { :player_name => player.name, 
                         :initial_stack => player.current_stack,
                         :current_bet => 50,
                         :actions => antes + [{:action => "bet", :amount => 50}]},
                       { :player_name => player2.name, 
                         :initial_stack => player2.current_stack,
                         :current_bet => @table.current_round.ante,
                         :actions => antes}
                     ]
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

    it "knows the minimum bet" do
      subject.to_json[:minimum_bet].should == @table.current_round.ante      
      player.take_action! action: "bet", amount: @table.current_round.ante + 1
      subject.to_json[:minimum_bet].should == @table.current_round.ante + 1
    end

    it "knows the maximum bet" do
      subject.to_json[:maximum_bet].should == player.initial_stack
    end
  end
end
