Feature: Draw poker
  Because hold'em was so late 2012

  Background:
    Given a tournament is open

  Scenario: Simplest table
    When 2 players are at a table
    And player 1 bets 24
    And player 2 folds
    Then player 1 wins the round

  Scenario: Betting above maximum bet
    When 2 players are at a table
    And player 1 bets 50
    Then player 2 cannot bet 1000

  Scenario: Betting below minimum bet
    When 2 players are at a table
    Then player 1 cannot bet -1

  Scenario: Going all in
    When 2 players are at a table with initial stacks [50, 100]
    Given the deck favors player 1
    When player 1 goes all in
    And player 2 goes all in
    And all players replace no cards
    Then player 1 wins 100
    And player 2 wins 50

  Scenario: Dealer goes all in
    When 2 players are at a table with initial stacks [100, 50]
    Given the deck favors player 2
    When player 1 goes all in
    And player 2 goes all in
    And all players replace no cards
    Then player 2 wins 100
    And player 1 wins 50

  Scenario: Player goes all in and loses
    When 2 players are at a table with initial stacks [100, 50]
    Given the deck favors player 1
    When player 1 bets 50
    And player 2 goes all in
    And all players replace no cards
    Then player 1 wins 110
    And player 2 is unseated

  Scenario: 2 players split the pot at a simple table
    When 2 players are at a table
    Given the deck favors both players
    When player 1 bets 80
    And player 2 bets 0
    And all players replace no cards
    And player 1 bets 0
    And player 2 bets 50
    And player 1 bets 0
    Then player 1 and player 2 split the pot
  
  Scenario: 2 players split the pot at a larger table
    When 3 players are at a table
    Given the deck favors player 1 and player 2
    When player 1 bets 80
    And player 2 bets 0
    And player 3 bets 0
    And all players replace no cards
    And player 1 bets 0
    And player 2 bets 0
    And player 3 bets 0
    Then player 1 and player 2 split the pot

  Scenario: A player cannot meet the ante but wins
    When 2 players are at a table with initial stacks [5, 25]
    Given the deck favors player 1
    And player 2 goes all in
    And all players replace no cards
    Then player 1 wins 10
    And player 2 wins 20

  Scenario: A player cannot meet the ante and loses
    When 2 players are at a table with initial stacks [5, 25]
    Given the deck favors player 2
    And player 2 goes all in
    And all players replace no cards
    Then player 2 wins 30
    And player 1 is unseated

