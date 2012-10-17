Feature: Action steps
  We want to describe all of the possible sequences of actions in 5 card draw poker

  Background:
  Given a tournament is open
  
  Scenario: Simplest table
    When 2 players are at a table
    And player 1 bets 10
    And player 2 folds
    Then player 1 wins the round

  Scenario: Betting above maximum bet
    When 2 players are at a table
    And player 1 bets 10
    Then player 2 cannot bet 1000
  
  Scenario: Betting below minimum bet
    When 2 players are at a table
    Then player 1 cannot bet -4
  
@wip
  Scenario: Going all in
    When 2 players are at a table
    Given the deck favors player 1
    When player 1 goes all in
    And player 2 goes all in
    And all players replace no cards
    Then player 1 wins the round
  
  Scenario: 2 players split the pot at a simple table
    When 2 players are at a table
    Given the deck favors both players
    When player 1 bets 100
    And player 2 bets 100
    And all players replace no cards
    And player 1 bets 0
    And player 2 bets 50
    And player 1 bets 50
    Then player 1 and player 2 split the pot
  
  Scenario: 2 players split the pot at a larger table
    When 3 players are at a table
    Given the deck favors player 1 and player 2
    When player 1 bets 100
    And player 2 bets 100
    And player 3 bets 100
    And all players replace no cards
    And player 1 bets 100
    And player 2 bets 100
    And player 3 bets 100
    Then player 1 and player 2 split the pot

  
