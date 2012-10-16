Feature: Player Registration
  We want to allow students to register for tournaments
  
  Scenario: Successful registration
    Given a tournament is open
    When I POST to "/api/players" with:
      | name    | Team4   |
    Then a new player should be registered for that tournament
    And the JSON response should include entries:
      | name    | Team4   |
      | key     | {{@player.key}} |

  Scenario: Unsuccessful registration
    Given no tournament is open
    When I POST to "/api/players" with:
      | name    | Team4   |
    Then the response status should be 404
    And the JSON response should include entries:
      | error   | The tournament is currently closed. |

