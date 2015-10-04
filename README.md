# Busyverse

[ ![Codeship Status for jweissman/busyverse](https://www.codeship.io/projects/9c8a5150-0a08-0133-3248-521d3b82cdba/status)](https://codeship.com/projects/90649)

![In-game Screenshot](https://raw.github.com/jweissman/busyverse/master/img/busyverse-lg.png)
A city-building game. You control workers by giving them commands. 

## Requirements

Ruby 2.2.2. No system dependencies so far. The game engine is entirely in JS and configuration is currently all in code, so no database required yet.

![In-game Screenshot](https://raw.github.com/jweissman/busyverse/master/img/busyverse-sm.png)

## Getting Started

This is a Coffeescript game running inside a Ruby on Rails project. 

Run `bundle exec rake` to run the test suite.  

A `bundle exec rails s` will fire up the server. 

You should now be able to play the game at http://localhost:3000. 

You should also now be able to view test suite output at http://localhost:3500.

## Playing the Game

You start off overlooking a Small Farm. Click around the map to scroll. Use +/- to scroll.

You will see a few **workers** with a badge indicating their name and current task. Their initial task will be to *wander* and uncover the map. 

You can use the text bar at the top to give them commands, like *gather* which will cause them to search around them for resources to pick up.

These resources let you construct buildings with the **building palette**, just below the city name and resource list widgets. 

Click on the name of a building and then click where on the map you'd like to build it. 

A building will be greyed out if you cannot place it somewhere (because of terrain or structures in the way).
