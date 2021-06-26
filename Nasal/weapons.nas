var masterarm = props.globals.getNode("controls/armament/master-arm");
var weapselected = props.globals.getNode ("sim/armament/weapon_selected");
var gun0 = props.globals.getNode("sim/armament/gun[0]/fire");
var gun1 = props.globals.getNode("sim/armament/gun[1]/fire");
var gun2 = props.globals.getNode("sim/armament/gun[2]/fire");
var gun3 = props.globals.getNode("sim/armament/gun[3]/fire");

var statgun0 = props.globals.getNode("sim/armament/gun[0]/serviceable");
var statgun1 = props.globals.getNode("sim/armament/gun[1]/serviceable");
var statgun2 = props.globals.getNode("sim/armament/gun[2]/serviceable");
var statgun3 = props.globals.getNode("sim/armament/gun[3]/serviceable");

var cannon0 = props.globals.getNode("sim/armament/cannon[0]/fire");
var statcannon0 = props.globals.getNode("sim/armament/cannon[0]/serviceable");

var tracerevery = 20;
		var times0 = 49;


var rocket0 = props.globals.getNode("sim/armament/rocket[0]/fire");

var statrocket0 = props.globals.getNode("sim/armament/rocket[0]/serviceable");

var rpmode = props.globals.getNode("sim/armament/rpmode");

var drop_tank = func () {
		print ("dropping Tank");
		setprop ("sim/armament/pylon[1]/release_tank", 1);
		setprop ("sim/armament/pylon[1]/type", 0);
		setprop ("consumables/fuel/tank[1]/capacity-gal_us",0);
}

var drop_bomb = func () {
		print ("dropping bomb!");
		var packet = getprop ("sim/armament/bombpacket");
		var dropped = 0;
		var timed = getprop ("sim/armament/bombtrain");
		var single = getprop ("sim/armament/bombsingle");

		if ( getprop ("sim/armament/pylon[1]/type") == 3 or getprop ("sim/armament/pylon[1]/type") == 4 ) {
				setprop ("sim/armament/pylon[1]/type", 1);
				setprop ("sim/armament/pylon[1]/release_bomb", 1);
				setprop ("weight[0]/lbs",0);
				dropped = dropped+1;
		} 

		print (dropped);
		if (dropped != 0 and single == 0) { 
				settimer (drop_bomb, timed);
		} else {
				print ("no Bomb left!");
		}
}
 
var fire_rocket = func () {

		print ("launching Rocket!"); 
		var packet = getprop ("sim/armament/rocketpacket");
		var launched = 0;
		var timed = getprop ("sim/armament/rockettrain");
		var single = getprop ("sim/armament/rocketsingle");
		if ( getprop ("sim/armament/pylon[0]/type") == 2 ) {
				setprop ("sim/armament/pylon[0]/type", 3);
				setprop ("sim/armament/pylon[0]/fire_rocket", 1);
				setprop ("weight[0]/lbs",0);
				settimer (func {find_rocket(0)},0.02);
				launched = launched+1;
		} 
		if ( launched < packet ) {
				if ( getprop ("sim/armament/pylon[2]/type") == 2 ) {
						setprop ("sim/armament/pylon[2]/type", 3);
						setprop ("sim/armament/pylon[2]/fire_rocket", 1);
						setprop ("weight[2]/lbs",0);
						settimer (func {find_rocket(2)},0.02);
						launched = launched+1;
				}
		} 
	#	print (launched);
		if (launched != 0 and single == 0) { 
				settimer (fire_rocket, timed);
		} else {
				print ("no Rocket left!");
		}

}

var find_rocket = func (num) {
		print ("Num: ",num);
		var loop = 0;
		var count = 0;
		while (loop == 0 ) {
			var nodename = "ai/models/ballistic[" ~ count ~"]/name";
		#	print ("Name: ", nodename);
		#	var name0 = getprop ("ai/models/ballistic[" ~ count ~"]/name");
		#	print (name0);
			if (getprop (nodename) == "wgr" ~ num ~"") {
					print ("Found ", getprop (nodename));
					loop = 1 ;
					update_rocket (count, num);
					}
			count = count+1;
			if ( count >10 ) {
					loop =1 ;
			}
		}


}


var update_rocket = func (nodecount, pylonnum) {
		var rocket_elev = getprop ("ai/models/ballistic[" ~ nodecount ~"]/orientation/pitch-deg");
		var rocket_hdg = getprop ("ai/models/ballistic[" ~ nodecount ~"]/orientation/hdg-deg");

		setprop ("sim/armament/pylon[" ~ pylonnum ~ "]/force/force-elevation-deg", rocket_elev);
		setprop ("sim/armament/pylon[" ~ pylonnum ~ "]/force/force-azimuth-deg", rocket_hdg);		
		setprop ("sim/armament/pylon[" ~ pylonnum ~ "]/force/force-lb", 3000);
		settimer (func {update_rocket(nodecount, pylonnum)},0.02);
}

setlistener("/controls/armament/trigger", func(n) {
  var stat = n.getValue();
  if 	( stat ) {
    if ( masterarm.getValue() )  {
      if (statgun0.getValue() == 1) {
        gun0.setValue (1);
      }
      if (statgun1.getValue() == 1) {
        gun1.setValue (1);
      }
    }
  } else {
       gun0.setValue (0);
       gun1.setValue (0);

  }
});

setlistener("/controls/armament/trigger1", func(n) {
  var stat = n.getValue();
    if 	( stat ) {
      if ( masterarm.getValue() )  {
        if (statcannon0.getValue() == 1) {
          cannon0.setValue (1);
        }
        if (statgun2.getValue() == 1) {
          gun2.setValue (1);
        }
        if (statgun3.getValue() == 1) {
          gun3.setValue (1);
        }
      }
    } else {
      cannon0.setValue (0);
      gun2.setValue (0);
      gun3.setValue (0);
    }

});

setlistener("/controls/armament/trigger2", func(n) {
  var stat = n.getValue();
  if 	( stat ) {
    if ( masterarm.getValue() )  {
      if (weapselected.getValue() == 1 ) {
        drop_bomb();
      }
 #     if (weapselected.getValue() == 2 ) {
 #       drop_tank();
 #     }
      if (weapselected.getValue() == 3 ) {
        fire_rocket();
      }
 #      if (weapselected.getValue() == 4 ) {
 #        fire_sidewinder();
 #      }
    }
  }
});




setlistener("sim/model/aircraft/impact/gun", func(n) {
    var impact = n.getValue();
    var solid = getprop(impact ~ "/material/solid");
    
    if (solid) {
#      var long = getprop(impact ~ "/impact/longitude-deg");    
#      var lat = getprop(impact ~ "/impact/latitude-deg");
			setprop("sim/model/aircraft/impact/splash",0);
    }
		else {
			setprop("sim/model/aircraft/impact/splash",1);
		}
  });


var cannonflash_trigger = props.globals.getNode("sim/armament/cannon[0]/fire", 0);
aircraft.light.new("sim/model/cannon/flash", [0.03, 0.044], cannonflash_trigger);

var gunflash0_trigger = props.globals.getNode("sim/armament/gun[0]/fire", 0);
aircraft.light.new("sim/model/gun0/flash", [0.02, 0.034], gunflash0_trigger);

var gunflash1_trigger = props.globals.getNode("sim/armament/gun[1]/fire", 0);
aircraft.light.new("sim/model/gun1/flash", [0.025, 0.029], gunflash1_trigger);

var gunflash2_trigger = props.globals.getNode("sim/armament/gun[2]/fire", 0);
aircraft.light.new("sim/model/gun2/flash", [0.02, 0.034], gunflash2_trigger);

var gunflash3_trigger = props.globals.getNode("sim/armament/gun[3]/fire", 0);
aircraft.light.new("sim/model/gun3/flash", [0.025, 0.029], gunflash3_trigger);
