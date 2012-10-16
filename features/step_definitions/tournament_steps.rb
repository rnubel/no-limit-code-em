Given /^(\d+) players are registered$/ do |n|
  n.to_i.times do
    FactoryGirl.create(:player, :tournament => @tournament)
  end
end

When /^the tournament starts$/ do
  @tournament.start!
end

Then /^the tournament should have (\d+) table.?$/ do |n|
  @tournament.should have(n.to_i).tables
end

Then /^(\d+) table.? should have (\d+) players$/ do |n, p|
  @tournament.tables.select { |t| t.players.count == p.to_i }.size.should == n.to_i
end

