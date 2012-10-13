require 'spec_helper'

describe Round do
  subject { FactoryGirl.create(:round) }
  
  describe "its deck" do
    it "should have 52 cards" do
      subject.deck.split(" ").size.should == 52
    end
  end

  describe "its ante" do
    it "is set by a call to table.tournament.current_ante on creation" do
      Tournament.any_instance.expects(:current_ante).returns(100)

      subject.ante.should == 100
    end
  end
end
