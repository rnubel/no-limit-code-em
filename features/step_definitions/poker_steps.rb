Given /^(\d+) players are at a table$/ do |n|
  n.to_i.times do
    FactoryGirl.create(:player, :tournament => @tournament)
  end
  @tournament.start!
  @table = @tournament.tables.first
  @round = @table.current_round
end

Given /^(\d+) players are at a table with initial stacks \[(.*)\]$/ do |n, stack_list|
  stacks = stack_list.split(", ")
  n.to_i.times do |i|
    FactoryGirl.create(:player, :tournament => @tournament, :initial_stack => stacks[i])
  end
  @tournament.start!
  @table = @tournament.tables.first
  @round = @table.current_round
end

When /^player (\d+) bets (\d+)$/ do |id, amount|
  @player = @table.players[id.to_i-1]
  @player.take_action!(:action => "bet", :amount => amount.to_i)
end

When /^player (\d+) calls$/ do |id|
  @player = @table.players[id.to_i-1]
  @player.take_action!(:action => "call")
end

When /^player (\d+) checks$/ do |id|
  @player = @table.players[id.to_i-1]
  @player.take_action!(:action => "check")
end

When /^player (\d+) folds$/ do |id|
  @player = @table.players[id.to_i-1]
  @player.take_action!(:action => "fold")
end

Then /^player (\d+) wins the round$/ do |id|
  @player = @table.players[id.to_i-1]
  @table.rounds.order("id ASC").first.winners.keys.should == [@player]
end

Then /^player (\d+) wins (\d+)$/ do |id, amount|
  @player = @table.players[id.to_i-1]
  @table.rounds.order("id ASC").first.winners[@player].should == amount.to_i
end

Then /^player (\d+) cannot bet (-?\d+)$/ do |id, amount|
  @player = @table.players[id.to_i-1]
  @player.valid_action?(:action => "bet", :amount => amount.to_i).should be_false
end

Then /^turn stops at player (\d+)$/ do |id|
  @player = @table.players[id.to_i-1]
  @round.current_player.should == @player
end

When /^player (\d+) goes all in$/ do |id|
  @player = @table.players[id.to_i-1]
  @player.take_action!(:action => "bet", :amount => [@player.initial_stack - @player.current_game_state(:minimum_bet), 0].max)
end

When /^all players replace no cards$/ do
  @round.ordered_players.each do |player|
    player.take_action!(:action => "replace", :cards => [])
  end
end

Given /^the deck favors player 1$/ do
  if @tournament.game_type == 'draw_poker'
    @round.deck = "Ac 5d 2c 3d 3c 9s 4c 8h 5c Kh 2s 3s 5s 6s"
  else
    #              P1 P2 P1 P2 X  F  F  F  X  T  X  R
    @round.deck = "Ac 5d 2c 8d 7s 3c 4c 5c 6s 7s 7s 9s"
  end

  @round.save!
end

Given /^the deck favors player 2$/ do
  if @tournament.game_type == 'draw_poker'
    @round.deck = "Ac 5d 2c 3d 3c 9s 4c 8h 5c Kh 2s 3s 5s 6s".split(" ").reverse.join(" ")
  else
    @round.deck = "5d Ac 8d 2c 7s 3c 4c 5c 6s 7s 7s 9s"
  end

  @round.save!
end

Then /^player (\d+) is unseated/ do |id|
  @player = @table.players[id.to_i-1]
  @player.seatings.first.should_not be_active
end

Given /^the deck favors both players$/ do
  @round.deck = "Ac Ad 2c 2d 3c 3d 4c 4d 5c 5d"
  @round.save
end

Then /^player (\d+) and player (\d+) split the pot$/ do |p1_id, p2_id|
  @player_one = @table.players[p1_id.to_i-1]
  @player_one.round_players.order("id ASC").first.stack_change.should >= 0
  @player_two = @table.players[p2_id.to_i-1]
  @player_two.round_players.order("id ASC").first.stack_change.should >= 0
end

Given /^the deck favors player 1 and player 2$/ do 
  if @tournament.game_type == 'draw_poker'
    @round.deck = "Ac Ad Ah 2c 2d 2h 3c 3d 3h 4c 4d 4h 5c 5d 6d"
  else
    #              P1 P2 P3 P1 P2 P3 X  F  F  F  X  T  X  R
    @round.deck = "Ac Ad 9s As Ah 8c 7c 3c 3d 4c 4d 4h 5c 5d"
  end

  @round.save!
end

When /I log player 1's status/ do
  puts PlayerPresenter.new(@table.players[0]).to_json
end
