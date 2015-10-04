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
  width:  800,
  height: 800,

  cellSize: 10,

  bufferSize: 16000,

  stepLength: 24,
    
  initialPopulation: 6,
  startingResources: 600,
  defaultVisionRadius: 4,

  scale: 0.71,

  evolveDepth: 15, // how long to smooth/evolve landscape

  // banner
  banner: " _                                   \n"+        
          "| |_ _ _ ___ _ _ _ _ ___ ___ ___ ___ \n"+ 
          "| . | | |_ -| | | | | -_|  _|_ -| -_|\n"+ 
          "|___|___|___|_  |\\_/|___|_| |___|___|\n"+
          "            |___|                    \n"+
          "                   v0.0.1",

  // language
  humanNames: [ "Alain", "Ferris", "Orff", "Enoch", "Carol", "Sam", "Deborah", "Liam", "Thiago", "Elias", "Sem", "Allard", "Artemis", "Stephanie", "Estrella", "Simon", "Paul", "Gilles", "Mia", "Anya", "Jen", "Ana", "Amelie", "Augustine", "Aaron", "Anton", "Andre", "Anders", "Ahmed", "Emma", "Lucas", "Bob", "Amy", "John", "Kevin", "Tom", "Alex", "Brad", "Carrie", "Sofia", "Elisabeth", "Luka", "Gabriel", "Felix", "Jean-Paul", "Michel", "Antoine", "Mohamed", "Fatima", "Juan", "Ali", "Hiroto", "Eden", "Maria", "Lisbet", "George", "Gina", "Dean", "Sarah", "Cindy", "Terrence", "Clark", "Karim", "Isabel", "William", "Aya" ],


  // google sheet api ids
  buildingSheetId: '1D4tS4SUO2d4Y2NQ58gQPGpiIsl9vn6zBz4igCKyOCf0' // new busyverse
     // '1Zj0wx8Uag4pwUEq641r0ICTmr983Qp2OSCcPIpyMcGE' -- old busyverse
};
