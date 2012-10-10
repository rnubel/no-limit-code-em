require 'spec_helper'

describe Tournament do
  it "should be open or closed" do
    Tournament.create(open: true).open?.should be_true
    Tournament.create(open: false).open?.should be_false
  end

  it "should have many players" do
    t = Tournament.create
    t.players.push(FactoryGirl.create(:player))

    t.players.size.should == 1
  end

  context "when starting" do
    let(:tournament) { Tournament.create open: true }

    before :each do
      5.times do
        tournament.players << FactoryGirl.create(:player)
      end

      tournament.start! table_size: 4
    end

    it "should close itself" do
      tournament.open?.should be_false
    end

    it "should create tables to seat players evenly" do
      tournament.tables.size.should == 2
      tournament.tables.first.players.size.should == 3
      tournament.tables.last.players.size.should == 2
    end
  end

  context "when redistributing" do
   
  end
end
