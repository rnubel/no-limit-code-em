require 'spec_helper'

describe Action do
  it "requires an action name" do
    Action.new.valid?.should be_false  
  end
end
