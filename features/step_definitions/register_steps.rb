Given /^a tournament is open$/ do
  @tournament = Tournament.create open: true, game_type: 'draw_poker'
end

Given /^a hold'em tournament is open$/ do
  @tournament = Tournament.create open: true, game_type: 'hold_em'
end

Given /^no tournament is open$/ do
  Tournament.open.each do |t| t.open = false; t.save; end
end

Then /^a new player should be registered for that tournament$/ do
  @tournament.reload.should have(1).player
  @player = @tournament.players.last
end

Given /^a player is registered$/ do
  @tournament.players << FactoryGirl.build(:player)
  @tournament.save!
  @player = @tournament.players.last
end

