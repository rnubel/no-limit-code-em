require 'spec_helper'

describe Tournament do
  it "is open or closed" do
    Tournament.create(open: true).open?.should be_true
    Tournament.create(open: false).open?.should be_false
  end

  it "starts out as not playing" do
    Tournament.create(open: true).should_not be_playing
  end

  it "allows players to register" do
    t = Tournament.create
    t.register_player!(FactoryGirl.create(:player))

    t.players.size.should == 1
  end

  subject { Tournament.create open: true }

  before :each do
    subject.stubs(:table_size).returns(4)

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
        subject.tables[0].should have(3).active_players
        subject.tables[1].should have(2).active_players
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
             subject.players.first.unseat!
             subject.balance_tables! }

    pending { should have(1).tables }
  end

  describe "#current_ante" do
    it "is fixed at 20 FIXME" do
      subject.current_ante.should == 20 
    end
  end
end
