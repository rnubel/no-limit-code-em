Feature: Action steps
  We want to describe all of the possible sequences of actions in 5 card draw poker

  Background:
	Given a tournament is open
  
  Scenario: Simplest table
    And 2 players are at a table
	When player 1 bets 10
	When player 2 folds
	Then player 1 wins the round

  Scenario: Betting above maximum bet
	And 2 players are at a table
	When player 1 bets 10
	Then player 2 cannot bet 1000
	
  Scenario: Betting below minimum bet
	And 2 players are at a table
	Then player 1 cannot bet -4
	
@wip
  Scenario: Going all in
	And 2 players are at a table
	Given the deck favors player 1
	When player 1 goes all in
	When player 2 goes all in
	When all players replace no cards
	Then player 1 wins the round
	
  Scenario: 2 players split the pot at a simple table
    And 2 players are at a table
	Given the deck favors both players
	When player 1 bets 100
	When player 2 bets 100
	When all players replace no cards
	When player 1 bets 0
	When player 2 bets 50
	When player 1 bets 50
	Then player 1 and player 2 split the pot
	
  Scenario: 2 players split the pot at a larger table
    And 3 players are at a table
	Given the deck favors player 1 and player 2
	When player 1 bets 100
	When player 2 bets 100
	When player 3 bets 100
	When all players replace no cards
	When player 1 bets 100
	When player 2 bets 100
	When player 3 bets 100
	Then player 1 and player 2 split the pot

