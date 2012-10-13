require 'spec_helper'

describe TableLogic do
  context "when included into Array" do
    before(:all) { Array.send :include, TableLogic }

    describe "#each_in_tables" do
      it "iterates over 6 players in one step" do
        1.upto(6).to_a.each_in_tables.to_a.should == [
          [1, 2, 3, 4, 5, 6]
        ]
      end

      it "iterates over 20 players in four steps of 5" do
        1.upto(20).to_a.each_in_tables.to_a.should == [
          [1, 5, 9, 13, 17],
          [2, 6, 10,14, 18],
          [3, 7, 11,15, 19],
          [4, 8, 12,16, 20]
        ]
        
      end

      it "iterates over 22 players in two steps of 6 and two of 5" do
         1.upto(22).to_a.each_in_tables.to_a.should == [
          [1, 5, 9, 13, 17, 21],
          [2, 6, 10,14, 18, 22],
          [3, 7, 11,15, 19],
          [4, 8, 12,16, 20]
        ]
      end

      it "iterates over 3 players in one step of 3" do
        [1, 2, 3].each_in_tables.to_a.should == [
          [1, 2, 3]
        ]
      end

      it "does not iterate over 0 players" do
        [].each_in_tables.to_a.should == []
      end

      it "calls the enumerator when a block is given" do
        x = nil
        [1, 2, 3].each_in_tables do |table|
          x = table
        end

        x.should == [1, 2, 3]
      end
    end
  end
end
