Feature: Texas Hold'Em
  Because draw poker is so early 2013

  Background:
    Given a hold'em tournament is open

  Scenario: Simplest table
    When 2 players are at a table
    # Player 1 is the dealer. So, player 2 posts small blind, and player 1 posts big blind.
    # Player 2 is therefore the first to act:
    And player 2 bets 24
    And player 1 folds
    Then player 2 wins the round

  Scenario: Betting above maximum bet
    When 2 players are at a table
    And player 2 bets 50
    Then player 1 cannot bet 1000

  Scenario: Betting below minimum bet
    When 2 players are at a table
    Then player 2 cannot bet -1

  Scenario: Going all in
    Given 2 players are at a table with initial stacks [50, 100]
    And the deck favors player 1
    When player 2 goes all in
    And player 1 goes all in
    # Refund extra pot to player 2
    Then player 2 wins 50
    And player 1 wins 100

  Scenario: Player goes all in and loses
    Given 2 players are at a table with initial stacks [100, 50]
    And the deck favors player 1
    When player 2 goes all in
    And player 1 calls
    Then player 1 wins 100
    And player 2 is unseated

  Scenario: Dealer, not chip leader, goes all in and loses
    Given 2 players are at a table with initial stacks [50, 100]
    And the deck favors player 2
    When player 2 goes all in
    And player 1 calls
    Then player 2 wins 150
    And player 1 is unseated

  Scenario: 2 players split the pot at a larger table
    When 3 players are at a table
    Given the deck favors player 1 and player 2
    # 2 small blinds, 3 big blinds, 1 starts
    When player 1 bets 80
    And player 2 calls
    And player 3 calls
    # 2 starts the flop
    And player 2 checks
    And player 3 checks
    And player 1 checks
    # 2 starts the turn
    And player 2 checks
    And player 3 checks
    And player 1 checks
    # 2 starts the river
    And player 2 checks
    And player 3 checks
    And player 1 checks
    Then player 1 and player 2 split the pot
