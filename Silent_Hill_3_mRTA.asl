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
    vars.ticking_puzzle = false;

    vars.Functions = new ExpandoObject();
    var F = vars.Functions;

    var state_values = new Dictionary<string , int>() {
      { "World", 5 },
      { "Inventory", 6 },
      { "Background", 11}
    };

    F.shouldTick = (Func<bool>)(() => {
        if(current.state0 != 2) { return false; }
        if(current.state1 == state_values["World"]) { return F.inWorld(); }
        if(current.state1 == state_values["Inventory"]) { return F.inInventory(); }
        if(current.state1 == state_values["Background"]) { return F.inBackground(); }
        return false;
    });

    F.inWorld = (Func<bool>)(() => {
      var explore = (current.eventid == -1) && (0 == current.is_paused);
      if(current.state2 < 2) {
        return explore;
      }
      return (current.state3 == 7) || (current.state3 == 10);
    });

    F.inInventory = (Func<bool>)(() => {
      if(current.state2 == 1 && current.state3 == 23) {
          return (current.state4 == 2) || (current.state4 == 3);                    // Examine Book
      }

      return true;
    });

    F.inBackground = (Func<bool>)(() => {
      vars.ticking_puzzle = vars.prev.state1 != 11 ? false : vars.ticking_puzzle;   // Checking for new frame

      if(vars.prev.counter != current.counter) {
        vars.ticking_puzzle = vars.prev.igt == current.igt ? false : true;
      }

      return vars.ticking_puzzle;
    });

    F.shouldTick();
}

update {
  vars.prev = old;
}

isLoading { 
  return !vars.Functions.shouldTick();
}