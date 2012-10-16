Given /^a tournament is open$/ do
  @tournament = Tournament.create :open => true
end

Given /^no tournament is open$/ do
  Tournament.open.each do |t| t.open = false; t.save; end
end

Then /^a new player should be registered for that tournament$/ do
  @tournament.reload.should have(1).player
  @player = @tournament.players.last
end
 

