require 'spec_helper'

describe Table do
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
