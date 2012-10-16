Feature: Player actions in a tournament
  In order for participants to play in the tournament
  They should be able to GET the status of a tournament and POST their actions

  Scenario: Status before tournament has started
    Given a tournament is open
    And a player is registered
    When I GET from "/api/players/{{@player.key}}"
    Then the JSON response should include:
      """
        {"name":  "{{@player.name}}",
         "stack": {{@player.stack}},
         "your_turn": false }
      """
