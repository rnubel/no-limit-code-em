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
         "initial_stack": null,
         "your_turn": false }
      """

  Scenario: Status when a tournament has started
    Given a tournament is open
    And 2 players are registered
    And the tournament starts
    When I am the dealer
    When I GET from "/api/players/{{@player.key}}"
    Then the JSON response should include:
      """
        {"name":  "{{@player.name}}",
         "initial_stack": {{@player.current_stack}},
         "your_turn": true }
      """

  Scenario: Posting a fold
    Given a tournament is open
    And 2 players are registered
    And the tournament starts
    When I am the dealer
    When I POST to "/api/players/{{@player.key}}/action" with:
      | action_name | fold |
    Then the JSON response should include:
      """
        {"name":  "{{@player.name}}",
         "initial_stack": {{@player.current_stack}}}
      """
    And the table's first round should be over

  Scenario: Posting a bet
    Given a tournament is open
    And 2 players are registered
    And the tournament starts
    When I am the dealer
    When I POST to "/api/players/{{@player.key}}/action" with:
      | action_name | bet |
      | amount      | 25  |
    Then the JSON response should include:
      """
        {"name":  "{{@player.name}}",
         "initial_stack": {{@player.current_stack}}}
      """
    And the table's first round should not be over

  Scenario: Replacement
    Given a tournament is open
    And 2 players are registered
    And the tournament starts
    And I am the dealer
    And I POST to "/api/players/{{@player.key}}/action" with:
      | action_name | bet |
      | amount      | 25  |
    And I am not the dealer
    And I POST to "/api/players/{{@player.key}}/action" with:
      | action_name | bet |
      | amount      | 25  |
    Then the table's first round should be in the "draw" betting round
    When I am the dealer  
    And I POST to "/api/players/{{@player.key}}/action" with:
      | action_name | replace |
      | cards       | {{@player.hand.first}} {{@player.hand.second}}  |
    Then the response status should be 200
    When I am not the dealer  
    And I POST to "/api/players/{{@player.key}}/action" with:
      | action_name | replace |
      | cards       | {{@player.hand.first}} {{@player.hand.second}}  |
    Then the response status should be 200
    Then the table's first round should be in the "post_draw" betting round
