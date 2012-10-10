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
end
