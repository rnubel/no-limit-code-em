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

When /I am the dealer/ do
  @player = @tournament.tables.ordered.first.reload.current_round.dealer
end

When /I am not the dealer/ do
  @player = @tournament.tables.ordered.first.reload.current_round.ordered_players.last
end

Then /^the table's first round should be over/ do
  @tournament.tables.first.rounds.ordered.first.should be_over
end

Then /^the table's first round should not be over/ do
  @tournament.tables.first.rounds.ordered.first.should_not be_over
end


Then /the table's first round should be in the "(.*)" betting round/ do |round|
  @tournament.tables.first.rounds.ordered.first.betting_round.should == round
end

When /^table (\d) loses (\d+) players?$/ do |id, n|
  @table = @tournament.tables.order("id ASC")[id.to_i-1]
  n.to_i.times do |i|
    @table.active_players.first.lose!
  end
end

When /^table (\d) finishes its round$/ do |id|
  @table = @tournament.tables.order("id ASC")[id.to_i-1]
  @table.next_round!
end

Then /^table (\d) should not be playing$/ do |id|
  @table = @tournament.tables.order("id ASC")[id.to_i-1]
  @table.should_not be_playing
end

When /^tables are balanced$/ do
  @tournament.balance_tables!
end

Then /^the tournament should have (\d+) playing tables?$/ do |n|
  @tournament.tables.playing.count.should == n.to_i
end

Then /^(\d+) players? should be standing/ do |n|
  @tournament.players.playing.standing.count.should == n.to_i
end
