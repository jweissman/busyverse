var Busyverse = {

  version: '0.0.1',

  trace:   false,
  debug:   false,
  verbose: false,
  
  // namespaces
  Buildings: {},
  Resources: {},

  Views: {},
  Support: {},
  Worker: {},

  // config
  width:  500,
  height: 500,

  cellSize: 10,

  bufferSize: 4000,

  stepLength: 20,
    
  startingResources: 650,
  defaultVisionRadius: 5,

  scale: 0.28,
  maxZoom: 0.7,

  evolveDepth: 26, // how long to smooth/evolve landscape

  // banner
  banner: " _                                   \n"+        
          "| |_ _ _ ___ _ _ _ _ ___ ___ ___ ___ \n"+ 
          "| . | | |_ -| | | | | -_|  _|_ -| -_|\n"+ 
          "|___|___|___|_  |\\_/|___|_| |___|___|\n"+
          "            |___|                    \n"+
          "                   v0.0.1",

  welcome: "Thanks so much for playing Busyverse! Please enjoy the game.",
  // language
  humanNames: [ "Alain", "Ferris", "Orff", "Enoch", "Carol", "Sam", "Deborah", "Liam", "Thiago", "Elias", "Sem", "Allard", "Artemis", "Stephanie", "Estrella", "Simon", "Paul", "Gilles", "Mia", "Anya", "Jen", "Ana", "Amelie", "Augustine", "Aaron", "Anton", "Andre", "Anders", "Ahmed", "Emma", "Lucas", "Bob", "Amy", "John", "Kevin", "Tom", "Alex", "Brad", "Carrie", "Sofia", "Elisabeth", "Luka", "Gabriel", "Felix", "Jean-Paul", "Michel", "Antoine", "Mohamed", "Fatima", "Juan", "Ali", "Hiroto", "Eden", "Maria", "Lisbet", "George", "Gina", "Dean", "Sarah", "Cindy", "Terrence", "Clark", "Karim", "Isabel", "William", "Aya" ],


  tips: ["* +/- to zoom", "* shift-click to recenter", "* space to return home","* type 'help' to list commands"],
  commands: ['gather', 'build', 'wander', 'idle'],
    
  // google sheet api ids
  buildingSheetId: '1D4tS4SUO2d4Y2NQ58gQPGpiIsl9vn6zBz4igCKyOCf0'

};
