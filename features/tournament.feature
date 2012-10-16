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
    Then the tournament should have 4 table
    And 3 tables should have 5 players
    And 1 tables should have 6 players
