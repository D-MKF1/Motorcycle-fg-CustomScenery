var flag = props.globals.initNode("/controls/flag",0,"INT");
var flagll = props.globals.initNode("/controls/flag-last-lap",0,"INT");
var flagvic = props.globals.initNode("/controls/flag-marshall-finish-line",0,"INT");
var smp = props.globals.initNode("/road-racer/show-mp-times",0,"BOOL");
var fr = props.globals.initNode("/controls/flag-rotation",0,"DOUBLE");
var thislapis = 0;

props.globals.initNode("/sim/menubar/default/menu[14]");
props.globals.initNode("/sim/menubar/default/menu[14]/enabled",1,"BOOL");
props.globals.initNode("/sim/menubar/default/menu[14]/label","ROADRACER","STRING");

props.globals.initNode("/sim/menubar/default/menu[14]/item");
props.globals.initNode("/sim/menubar/default/menu[14]/item/enabled",1,"BOOL");
props.globals.initNode("/sim/menubar/default/menu[14]/item/label","Live timing","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item/name","Button_1","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item/binding");
props.globals.initNode("/sim/menubar/default/menu[14]/item/binding/command","property-toggle","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item/binding/property","/road-racer/show-mp-times","STRING");

setlistener("/road-racer/show-mp-times", func(state) {
      var state = state.getValue() or 0;
      if (state){
        show_mp_times();
      }
});

############################ helper for view ####################################
var show_helper = func(s) {
  var hours = int(s / 3600);
  var minutes = int(math.mod(s / 60, 60));
  var seconds = math.mod(s, 60);
  var timestring = "";
  
	if (hours > 0){
  		timestring = sprintf("%3d : ", hours);
	}
	timestring = timestring~sprintf("%02d", minutes);	
	
	if (seconds < 10){
  		timestring = timestring~sprintf(" : 0%.1f", seconds);
	}else{
		timestring = timestring~sprintf(" : %.1f", seconds);
	}

	return timestring;
}


################## Calculate the sector and lap times for the combi instrument ###########
var calc_time = func(s) {
	var hours = s / 3600;
	var minutes = int(math.mod(s / 60, 60));
	var seconds = math.mod(s, 60);
	var time = [seconds,minutes,hours];

	return time;
}

############################### Show mp lap and sector times ####################################
var show_mp_times = func{

	# show mp times and set the flags of the road marshalls on multiplayer events
	
	var show_mp = getprop("/road-racer/show-mp-times") or 0;
	var ownflaginfo = getprop("/controls/flag-info") or 0;
	flag.setValue(0);
	flagll.setValue(0);
	flagvic.setValue(0);
		
    var mpOther = props.globals.getNode("/ai/models").getChildren("multiplayer");
    var otherNr = size(mpOther);
	var winpos = 1;
	var wintoppos = -60;
	var roadracer_list = {};
	var mytransponder = getprop("instrumentation/transponder/transmitted-id") or 0;
	var mycallsign = getprop("sim/multiplay/callsign") or 0;
	var myracelap = getprop("sim/multiplay/generic/int[1]") or 0;
	var mylaptime = getprop("sim/multiplay/generic/float[6]") or 0;
	var myracetime = getprop("sim/multiplay/generic/float[7]") or 0;
	var mylastlap = getprop("sim/multiplay/generic/float[8]") or 0;
	var myracefactor = (myracelap > 1) ? (myracetime-mylaptime)/(myracelap-1) : 999999; 
	
	# fill in your data in the hash
	if (mytransponder == 26) {
		roadracer_list[mycallsign] = {cs: mycallsign, ln:myracelap, ll:mylastlap, rt:myracetime, c:1, rf:myracefactor};
	}
	
	# fill in the multiplayer datas in the hash
	for(var v=0; v < otherNr; v+=1){

		if ((mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Suzuki-GSX-R/Models/Suzuki-GSX-R1000.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Honda-NSF/Models/Honda-NSF100.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/BMW-S-RR/Models/BMW-S1000RR.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/Honda-CBR-RR/Models/Honda-CBR-RR.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/Kawa-ZX10RR/Models/Kawa-ZX10RR.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/Suzuki-GSX-RR/Models/Suzuki-GSX-RR.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/Yamaha-YZF/Models/Yamaha-R1.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/Yamaha-YZF/Models/Yamaha-M1.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/KTM-RC16/Models/KTM-RC16.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/Ducati/Models/Panigale-1299R.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/Ducati/Models/Desmo-GP17.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/Motorcycle-Racing/Honda-RC213V/Models/Honda-RC214V.xml" or
			mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/LCR/Models/LCR-F2.xml")
			and mpOther[v].getNode("id").getValue() >= 0) {

			if(mpOther[v].getNode("sim/multiplay/generic/int[3]").getValue() == 1){
			
				# crashed
				if(flag.getValue() <= 3) flag.setValue(3);
				
			}else if(mpOther[v].getNode("sim/multiplay/generic/float[4]").getValue() > 0.9){
				
				# engine damage

				if(flag.getValue() <= 2) flag.setValue(2);
				
			}else if(mpOther[v].getNode("sim/multiplay/generic/float[4]").getValue() > 0.5){
				
				# engine trouble
				
				if(flag.getValue() <= 1) flag.setValue(1);
				
			}else{
				
				if(flag.getValue() <= 1) flag.setValue(1);
			}
			
			if(mpOther[v].getNode("sim/multiplay/generic/int[2]").getValue() == 6 or ownflaginfo == 6){
				flagll.setValue(1);
			}else if(mpOther[v].getNode("sim/multiplay/generic/int[2]").getValue() == 7 or ownflaginfo == 7){
				flagvic.setValue(1);
			}else if(mpOther[v].getNode("sim/multiplay/generic/int[2]").getValue() == 8 or ownflaginfo == 8){
				flag.setValue(5);
			}
			
			var racefactor = (mpOther[v].getNode("sim/multiplay/generic/int[1]",1).getValue() > 1) ? (mpOther[v].getNode("sim/multiplay/generic/float[7]",1).getValue()-mpOther[v].getNode("sim/multiplay/generic/float[6]",1).getValue())/(mpOther[v].getNode("sim/multiplay/generic/int[1]",1).getValue()-1): 999999;

			roadracer_list[v] = {cs: mpOther[v].getNode("callsign").getValue(), ln:mpOther[v].getNode("sim/multiplay/generic/int[1]",1).getValue(), ll:mpOther[v].getNode("sim/multiplay/generic/float[8]",1).getValue(), rt:mpOther[v].getNode("sim/multiplay/generic/float[7]",1).getValue(), c:1, rf:racefactor};

		}
	}


	#return a sorted list
	var lastlapresult = sort(keys(roadracer_list), func (a,b) { roadracer_list[a].ll - roadracer_list[b].ll; });
	var n = 1; #n=0 is the headline
	foreach (var i; lastlapresult){ 
		if(n == 1) roadracer_list[i].c = 0.5;
		n += 1;
	}
	
	var bestresult = sort(keys(roadracer_list), func (a,b) { roadracer_list[a].rf - roadracer_list[b].rf });
	var n = 1; #n=0 is the headline
	foreach (var i; bestresult){ 
		var race_win = screen.window.new( -6, wintoppos, 1, 1.1 );
		race_win.fg = [1,1,1,1]; # color first three rgb
		thislapis = (roadracer_list[i].ln <= 1)? 0 : roadracer_list[i].ln - 1;
		race_win.write(show_helper(roadracer_list[i].rt)~" #"~thislapis);
		race_win = screen.window.new( -130, wintoppos, 1, 1.1 );
		if(roadracer_list[i].cs == getprop("/sim/multiplay/callsign")){
			race_win.fg = [1,1,0,1]; # color last three rgb
		}else{
			race_win.fg = [1,1,roadracer_list[i].c,1]; # color last three rgb
		}
		race_win.write(n~". "~roadracer_list[i].cs~": ");	
		wintoppos += -26;
		n += 1;
	}

	var flp = getprop("/controls/flag-rotation") or 0;
	var i = ( flp > 0) ? 0 : 1;
	if(flag.getValue() > 1){
		interpolate("/controls/flag-rotation", i, 1.1);
	}else{
		setprop("/controls/flag-rotation", 0);
	}

	if(show_mp) settimer(show_mp_times,1.1);
}

show_mp_times();

fgcommand("gui-redraw");
