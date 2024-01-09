state("sh3") {
  byte is_paused: 0x7cc634;

  int state0: 0x7cc65c;
  int state1: 0x7cc660;
  int state2: 0x7cc664;
  int state3: 0x7cc668;
  int state4: 0x7cc66c;

  int eventid: 0x7a9768;
  float igt: 0x6ce66f4;
  int counter: 0x2b2a98;
}

init {
  refreshRate = 100;
  vars.ticking_puzzle = 0;
  vars.should_tick = (Func<bool>) (() => {
    if(current.state0 != 2) { return false; }
    
    //WORLD MODE
    if(current.state1 == 5) {

      //EXPLORE 
      if((0 == current.state2) || (1 == current.state2)) {
        return (current.eventid == -1) && (0 == current.is_paused);
      }

      //TEXT BOX 
      if(current.state2 == 2) {
        return (current.state3 == 7) || (current.state3 == 10);
      }
    }
    
    //INVENTORY MODE 
    if(current.state1 == 6) {
      //TODO: Don't count menu open because there is a load?
      //Original behavior is to count the load.

      if(current.state2 == 1) {

        //OPEN MENU
        if(current.state3 == 2) {
          //TODO: This is where logic goes for first menu, or to disable menu open entirely.
        }

        //EXAMINE BOOK
        if(current.state3 == 23) {
          return (current.state4 == 2) || (current.state4 == 3);
        }
      }
      return true;
    }

    //BACKGROUND MODE
    if(current.state1 == 11) {

      //HACK: I test for the presence of a new frame, 
      //  then compare IGT to determine whether a puzzle needs to tick.
      // Original idea is from the old script.
      if(vars.prev.state1 != 11) {
        //Entering the puzzle
        vars.ticking_puzzle = 0;
      }
      if(vars.prev.counter != current.counter) {
        if(vars.prev.igt == current.igt) {
          if(vars.ticking_puzzle > 0) { vars.ticking_puzzle -= 1; }
        } else {
          vars.ticking_puzzle = 1;
        }
      }

      return (vars.ticking_puzzle != 0);
    }
    return false;
  });
}

update {
  vars.prev = old;
}

isLoading { 
  return !vars.should_tick();
}

