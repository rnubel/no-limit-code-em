Feature: Action steps
  We want to describe all of the possible sequences of actions in 5 card draw poker

  Background:
  Given a tournament is open
  
  Scenario: Simplest table
    When 2 players are at a table
    And player 1 bets 20
    And player 2 folds
    Then player 1 wins the round

  Scenario: Betting above maximum bet
    When 2 players are at a table
    And player 1 bets 50
    Then player 2 cannot bet 1000
  
  Scenario: Betting below minimum bet
    When 2 players are at a table
    Then player 1 cannot bet 1
  
  Scenario: Going all in
    When 2 players are at a table with initial stacks [50, 100]
    Given the deck favors player 1
    When player 1 goes all in
    And player 2 goes all in
    And all players replace no cards
    Then player 1 should win 100
    And player 2 should win 50
  
  Scenario: 2 players split the pot at a simple table
    When 2 players are at a table
    Given the deck favors both players
    When player 1 bets 100
    And player 2 bets 100
    And all players replace no cards
    And player 1 bets 100
    And player 2 bets 150
    And player 1 bets 150
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

  Scenario: A player cannot meet the ante
    When 2 players are at a table with initial stacks [5, 25]
    Given the deck favors player 1
    When player 2 goes all in
    And all players replace no cards
    Then player 1 wins the round
