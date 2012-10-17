require 'spec_helper'

describe PlayerPresenter do
  subject { PlayerPresenter.new(player) }

  describe("#to_json") {
    let(:player){ FactoryGirl.create(:player, :registered) }

    it "has the needed keys" do
      subject.to_json.keys.should =~ [:name, :stack, :your_turn, :players_at_table]
    end
  }

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
                         :stack => player.current_stack,
                         :current_bet => nil,
                         :actions => antes},
                       { :player_name => player2.name, 
                         :stack => player2.current_stack,
                         :current_bet => nil,
                         :actions => antes}
                     ]
      end

      it "knows the latest bet" do
        player.take_action! action: "bet", amount: "1"

        subject.players_at_table
          .should == [ { :player_name => player.name, 
                         :stack => player.current_stack,
                         :current_bet => 1,
                         :actions => antes + [{:action => "bet", :amount => 1}]},
                       { :player_name => player2.name, 
                         :stack => player2.current_stack,
                         :current_bet => nil,
                         :actions => antes}
                     ]
      end
    end
  end
end
