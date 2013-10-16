require 'spec_helper'

describe Api::PlayersController do
  context "when a player posts an action" do
    let!(:player) {
      FactoryGirl.create :player, :registered
    }

    before {
      player.tables << FactoryGirl.create(:table, :tournament => player.tournament)
      player.tables.first.players << FactoryGirl.create(:player, :tournament => player.tournament)
      player.tables.first.start_play!
    }

    it "records that raw request" do
      post :action, { :id => player.key, :action_name => "fdsdf", :amount => 10 }

      rl = RequestLog.where(:round_id => player.round.id, :player_id => player.id).first

      rl.should_not be_nil
      rl.body.should == request.raw_post
    end
  end
end
