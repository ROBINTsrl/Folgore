var sin = func(a) { math.sin(a * math.pi / 180.0) }
var cos = func(a) { math.cos(a * math.pi / 180.0) }

var hitx = props.globals.getNode("combat/hit/hit_x",1 );
var hity = props.globals.getNode("combat/hit/hit_y",1 );
var hitz = props.globals.getNode("combat/hit/hit_z",1 );

var hitlon = props.globals.getNode ("ai/models/model-impact/impact/longitude-deg");
var hitalt = props.globals.getNode ("ai/models/model-impact/impact/elevation-m");

var hitCoord = geo.Coord.new();



# gets called when an impact occurs
var check_hit = func () {
		var hitnodename = props.globals.getNode("ai/models/model-impact").getValue();
		var hitnode = props.globals.getNode(hitnodename);
   var impactType = hitnode.getNode("impact/type").getValue();
   var impactheading = hitnode.getNode("impact/heading-deg").getValue();
   var impactpitch = hitnode.getNode("impact/pitch-deg").getValue();
   var impactspeed = hitnode.getNode("impact/type").getValue();
   var impactname = hitnode.getNode("name").getValue();
   var impactmat = hitnode.getNode("material/name").getValue();
		var ammo = 12.7;

		print ("Terrain", impactType);
		print ("Material", impactmat);
		print (hitnodename);
		print (hitnode);
   var targetCoord = nil;
		hitCoord.set_latlon ( hitnode.getNode("impact/latitude-deg").getValue(), hitnode.getNode("impact/longitude-deg").getValue(), hitnode.getNode("impact/elevation-m").getValue());
#		print (hitCoord);
		if ( impactType != "terrain" ) {
         var aiNodes = props.globals.getNode("/ai/models").getChildren(impactType); 
#					print ("AI Nodes: ", props.globals.getNode("/ai/models"));
# call to determin what has been hit
         targetCoord = get_target(aiNodes, hitCoord, impactType, );
					print ("Impact: " , targetCoord );
# send impact data over MP
					setprop("sim/multiplay/generic/float[1]", hitnode.getNode("impact/latitude-deg").getValue());
					setprop("sim/multiplay/generic/float[2]", hitnode.getNode("impact/longitude-deg").getValue());
					setprop("sim/multiplay/generic/float[3]", hitnode.getNode("impact/elevation-m").getValue());
					setprop("sim/multiplay/generic/float[4]", impactheading);
					setprop("sim/multiplay/generic/float[5]", impactpitch);
					setprop("sim/multiplay/generic/float[6]", impactspeed);
					setprop("sim/multiplay/generic/float[7]", ammo);
		}		
}

var get_target = func ( node , hitCoord, type ) {
		var coord = geo.Coord.new ();
   var impactDistance = nil;

# iterate through the AI Nodes

		foreach ( var i ; node ) {
      coord.set_xyz(i.getNode("position/global-x").getValue(), i.getNode("position/global-y").getValue(), i.getNode("position/global-z").getValue());
      impactDistance = hitCoord.direct_distance_to(coord);
      if(impactDistance < 70) {
# check if target is combat enabled
							if ( i.getNode( "combat" ) != nil ) {
									
									var hitcount = i.getNode("hitcount").getValue();
       			 			var targetCallsign = i.getNode("callsign").getValue();

									i.getNode("hitcount").setValue(hitcount+1);
# if target is MP, send Target Callsign and altered hitcount over MP, the recieving end listens for its own callsign
									if ( type == "multiplayer" ) {
											setprop("sim/multiplay/generic/string[1]", targetCallsign);
											setprop("sim/multiplay/generic/float[0]", hitcount);


									}
									if ( impactType = "aircraft" ) {
											print ("AI-Aircraft");
					#						i.getNode("combat/hit/hit_x").setValue( hit_x );
					#						i.getNode("combat/hit/hit_y").setValue( hit_y );
					#						i.getNode("combat/hit/hit_z").setValue( hit_z );
											

									}
									settimer(func { reinit_hit() }, 2);
									return targetCallsign;
							} else {
									print ("no Combatant");
							}
					}
			 }
}

var reinit_hit = func {
		setprop("sim/multiplay/generic/string[1]", "nil");
		setprop("sim/multiplay/generic/float[0]", 0);
		setprop("sim/multiplay/generic/float[1]", 0);
		setprop("sim/multiplay/generic/float[2]", 0);
		setprop("sim/multiplay/generic/float[3]", 0);
		setprop("sim/multiplay/generic/float[4]", 0);
		setprop("sim/multiplay/generic/float[5]", 0);
		setprop("sim/multiplay/generic/float[6]", 0);
		setprop("sim/multiplay/generic/float[7]", 0);
}


setlistener( "ai/models/model-impact", check_hit);

setlistener("ai/models/bomb-impact", func(n) {
    var impact = n.getValue();
    var solid = getprop(impact ~ "/material/solid");
    print ("ground hit");
    if (solid)
    {
      var long = getprop(impact ~ "/impact/longitude-deg");    
      var lat = getprop(impact ~ "/impact/latitude-deg");
			var fused = getprop ("sim/armament/bomb_fused");
					print (fused);
					if ( fused != -1 ) {
							print ("armed ");
		     			settimer (func {geo.put_model( "Aircraft/F-86/Models/Effects/crater.ac", lat, long )}, fused);

					}
    }
});

