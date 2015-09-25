Feature: Creating a building
    As a player
    I want to create buildings
    In order to invent an awesome city

  @javascript
  Scenario: Create my first building
    Given I am on the game landing page
     When I click the canvas
     Then I see a new building
