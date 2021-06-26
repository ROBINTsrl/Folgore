var emptyw = 6502;
var breakload = 9;
var breakspeed = 415;
var bendload = 7;
var looptime = 0.2;
var flapoverspeed= 195;
var airspeed = props.globals.getNode("velocities/airspeed-kt");
var gload = props.globals.getNode("accelerations/pilot-g",1);
var weight = props.globals.getNode("yasim/gross-weight-lbs",1);
var flappos = props.globals.getNode("controls/flight/flaps",1);
var turn = props.globals.getNode("instrumentation/turn-indicator/indicated-turn-rate");
var fail_r = props.globals.getNode("sim/failure-manager/controls-failure-roll");
var fail_d = props.globals.getNode("sim/failure-manager/controls-failure-drag");
var aileron = props.globals.getNode("controls/flight/aileron");
var gear0 = props.globals.getNode("controls/gear/gear[0]/gear-down");
var gear1 = props.globals.getNode("controls/gear/gear[1]/gear-down");
var gear2 = props.globals.getNode("controls/gear/gear[2]/gear-down");
var nofuel = props.globals.getNode("engines/engine[0]/out-of-fuel",1 );
var engon = props.globals.getNode("engines/engine[0]/running",1 );
var hitx = props.globals.getNode("combat/hit/hit_x",1 );
var hity = props.globals.getNode("combat/hit/hit_y",1 );
var hitz = props.globals.getNode("combat/hit/hit_z",1 );
var hitvalid = props.globals.getNode("combat/hit/valid",1 );


var init = func {

		settimer(main_loop, looptime);
}


var main_loop = func {
		check_airframe();

  	settimer(main_loop, looptime);
}


var check_airframe = func {
	var gl = gload.getValue();
	var gw = weight.getValue();
	var as = airspeed.getValue();
	var slip = turn.getValue();
	var fail = fail_r.getValue();
	var ow = gw - emptyw;

# check flap deployment and failure due to overspeed
	if ( flappos.getValue() > 0 ) {

				if (as > flapoverspeed) {
						print ("flaps overspeed!");
						var load = as - flapoverspeed;
						print (load*flappos.getValue());
						if (load * flappos.getValue() > 20 ) {
								if (flappos.getValue() >= 0.5 ) {
										flappos.setValue(0);
										flappos.setAttribute("writable",0);
										setprop ("/sim/failure-manager/flaps", "1");
								}
						flappos.setValue(0);
						}
				}
		}

# check for excessive g-load or overspeed
		#print(gl, breakload - 0.0004 * ow );
	if (gl > (breakload - 0.0003 * ow) or (as > breakspeed)) {
		print ("break");
		if (slip < 0) {
			setprop ("sim/failure-manager/left-wing-torn", "1");
			fail_r.setValue(1);
		} else {
			setprop ("sim/failure-manager/right-wing-torn", "1");
			fail_r.setValue(-1);
		}
	}
	if (gl > (bendload - 0.0004 * ow)) {
		print ("bend");
		if (slip < 0) {
			gear0.setAttribute("writable",0);
		} else {
			gear1.setAttribute("writable",0);
		}
	}		
}


var kill_engine = func {
	nofuel.setValue(1);
	nofuel.setAttribute("writable", 0);
#	interpolate ("/engines/engine[0]/fuel-press", 0, 1);
#	interpolate ("/engines/engine[0]/mp-osi", 0, 1.5);
	
}


var process_hit = func {

		if (getprop("/hitcount" ) > 5 ) {
				var fail_prob = getprop ("/hitcount") + rand()*25;
				print ("Faliure Probability: ", fail_prob);
				if (fail_prob >= 40 ) {
						
						var fail_type = rand()*10;
						print ("Failure Type: ",fail_type);
						var state = getprop ("sim/failure-manager/fail-type");
						if (fail_type >= 6 ) {
								print ("Engine failure");
								kill_engine();
								setprop ("sim/failure-manager/smoking",1);
						} else if (fail_type >= 3 ) {
								print ("Fire");
								setprop ("sim/failure-manager/burning",2);
						} else {
								print ("Structural failure");
								tear_wing();
								# setprop ("sim/failure-manager/fail-type",3);
						}
				}
		}
	
}

var tear_wing = func {
									var slip = turn.getValue();
										if (slip < 0) {
												aileron.setValue(1);
												aileron.setAttribute("writable", 0);
										} else {
												aileron.setValue(-1);
												aileron.setAttribute("writable", 0);
										}
}

# lower gear
setlistener("/controls/gear/gear-down", func(n) {
#		print (n.getValue());
		if (n.getValue() == "1") {
				gear0.setValue("true");
				gear1.setValue("true"); 
				if (getprop ("controls/gear/tailwheel-steerable")) {
						gear3.setValue("true");
				} else {
						gear2.setValue("true");
				}
		} else {
				gear0.setValue("false");
				gear1.setValue("false"); 
				gear2.setValue("false");
	#			gear3.setValue("false");
		}
});

# check for propstrike
setlistener("/gear/gear[4]/compression-norm", func(n) {
		if (n.getValue() >=0.1 ) {
			if (getprop ("sim/failure-manager/engines/engine[0]/propstrike") != 1) {
				kill_engine();
				if (engon.getValue() == 1 ){
						setprop ("sim/failure-manager/engines/engine[0]/propstrike-force", 1);
				}
				setprop ("sim/failure-manager/engines/engine[0]/propstrike", 1);
				print("propsrtrike");
				interpolate ("sim/failure-manager/engines/engine[0]/propstrike-force",0 ,0.1);
			}
		}
});

setlistener("/sim/signals/fdm-initialized",init);
