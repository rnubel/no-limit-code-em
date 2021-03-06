Feature: Tournament seating
  We want players to be seated at tables with other players

  Scenario: Simplest possible tournament
    Given a tournament is open
    And 2 players are registered
    When the tournament starts
    Then the tournament should have 1 table
    And 1 table should have 2 players

  Scenario: More complex tournament
    Given a tournament is open
    And 21 players are registered
    When the tournament starts
    Then the tournament should have 4 tables
    And 3 tables should have 5 players
    And 1 tables should have 6 players

  Scenario: Basic reseating
    Given a tournament is open
    And 20 players are registered
    When the tournament starts
    Then the tournament should have 4 tables
    When table 1 loses 2 players
    And table 1 finishes its round
    Then table 1 should not be playing
    When tables are balanced
    Then the tournament should have 3 playing tables

  Scenario: Simultaneous reseating
    Given a tournament is open
    And 20 players are registered
    When the tournament starts
    Then the tournament should have 4 tables
    When table 1 loses 1 player
    And table 2 loses 1 player
    And table 3 loses 1 player
    And table 3 finishes its round
    Then table 3 should not be playing
    When tables are balanced
    Then the tournament should have 3 playing tables

  Scenario: Knockout reseating
    Given a tournament is open
    And 12 players are registered
    When the tournament starts
    When table 1 loses 5 players
    And table 2 loses 5 players
    And table 1 finishes its round
    And table 2 finishes its round
    When tables are balanced
    Then the tournament should have 1 playing table

  Scenario: A table goes down to 1 player with no room elsewhere
    Given a tournament is open
    And 18 players are registered
    When the tournament starts
    When table 1 loses 5 players
    And table 1 finishes its round
    When tables are balanced
    Then the tournament should have 2 playing tables
    And 1 player should be standing

