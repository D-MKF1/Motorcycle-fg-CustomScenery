#Canvas race map
print("");
props.globals.initNode("/sim/menubar/default/menu[14]");
props.globals.initNode("/sim/menubar/default/menu[14]/enabled",1,"BOOL");
props.globals.initNode("/sim/menubar/default/menu[14]/label","ROADRACER","STRING");

props.globals.initNode("/sim/menubar/default/menu[14]/item[2]");
props.globals.initNode("/sim/menubar/default/menu[14]/item[2]/enabled",1,"BOOL");
props.globals.initNode("/sim/menubar/default/menu[14]/item[2]/label","Map open","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[2]/name","Button_2","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[2]/binding");
props.globals.initNode("/sim/menubar/default/menu[14]/item[2]/binding/command","nasal","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[2]/binding/script","road_racer_map.open();","STRING");

props.globals.initNode("/sim/menubar/default/menu[14]/item[3]");
props.globals.initNode("/sim/menubar/default/menu[14]/item[3]/enabled",1,"BOOL");
props.globals.initNode("/sim/menubar/default/menu[14]/item[3]/label","Map close","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[3]/name","Button_3","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[3]/binding");
props.globals.initNode("/sim/menubar/default/menu[14]/item[3]/binding/command","nasal","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[3]/binding/script","road_racer_map.close();","STRING");

props.globals.initNode("/sim/menubar/default/menu[14]/item[4]");
props.globals.initNode("/sim/menubar/default/menu[14]/item[4]/enabled",1,"BOOL");
props.globals.initNode("/sim/menubar/default/menu[14]/item[4]/label","Map code reload","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[4]/name","Button_4","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[4]/binding");
props.globals.initNode("/sim/menubar/default/menu[14]/item[4]/binding/command","nasal","STRING");
props.globals.initNode("/sim/menubar/default/menu[14]/item[4]/binding/script","road_racer_map.close();io.load_nasal(getprop(\"/sim/fg-home\")~\"/Nasal/road_racer_map.nas\");road_racer_map.open();","STRING");

#io.load_nasal(getprop("/sim/fg-home")~"/Nasal/road_racer_map.nas");

var COLOR = {
	MapCenter : "#FF0000",
	BikeText  : "#FFFFFF",
	BikeGPS   : "#008800",
	Track	  : "#999999",
	Sector	  : "#666666",
	Background: "#000000",
};


var MyMap = {
	new : func(parent,name){
		var m = {parents:[MyMap,parent.createChild("map",name)]};
		m._parent = parent;
		m._name = name;
		m.RANGENM	= 1.6;
		m.RANGENM	= 1.852;
		m.RANGENM	= 1.852;
		m._screenSize	= 200;
		m._can = {
			point	: m.createChild("group","center"),
		};
		m._can.point.createChild("path", "icon")
			.setStrokeLineWidth(3)
			.setScale(1)
			.setColor(COLOR.MapCenter)
			.moveTo(-3, -3)
			.line(0, 6)
			.line(6, 0)
			.line(0, -6)
			.line(-6, 0)
			.setVisible(0)
			;
			
			
		return m;
	},
	setRefPos : func(lat, lon) {
	# print("RefPos set");
		me._node.getNode("ref-lat", 1).setDoubleValue(lat);
		me._node.getNode("ref-lon", 1).setDoubleValue(lon);
		me._can.point.setGeoPosition(lat,lon);
		me; # chainable
	},
	setHdg : func(hdg) { 
		me._node.getNode("hdg",1).setDoubleValue(hdg); 
		me; # chainable
	},
	setZoom : func(zoom){
		
		me._node.getNode("range", 1).setDoubleValue(zoom);
	},
	adjustZoom : func(amount){
		var range = me._node.getNode("range", 1).getValue();
		range += amount;
		if (range < 0.1){
			range = 0.1;
		}
		me._node.getNode("range", 1).setDoubleValue(range);
	},
	setScreenSize : func(pixel){
		me._screenSize	= pixel;
	},
	setRangeNm : func(nm){
		var range = 200 / (me._screenSize / nm);
		me._node.getNode("range", 1).setDoubleValue(range);
	},
};

var SpriteBike = {
	new : func(parent,name){
		var m = {parents:[SpriteBike]};
		m._can = {
			bike	: parent.createChild("group","bike"),
		};
		
		m._can.bike.createChild("path", "icon")
			.setStrokeLineWidth(3)
			.setScale(1)
			.setColor(COLOR.BikeGPS)
			.moveTo(-1, -1)
			.line(0, 4)
			.line(4, 0)
			.line(0, -4)
			.line(-4, 0);
		 
		 m._can.bike.createChild("text", "bike:" ~ name)
			.setFont("LiberationFonts/LiberationMono-Bold.ttf")
			.setTranslation(0,-8)
			.setFontSize(16, 1)
			.setColor(COLOR.BikeText)
			.setColorFill(COLOR.BikeText)
			.setAlignment("center-bottom-baseline" )
			.setText(name);
		 
		return m;
	},
	setRefPos : func(lat, lon) {
		me._can.bike.setGeoPosition(lat,lon);
		me; # chainable
	},
	setVisible : func(v){
		me._can.bike.setVisible(v);
	},
	setGeoPosition : func(lat,lon){
		me._can.bike.setGeoPosition(lat,lon);
	}
};

var RaceTrack = {
	new: func(name= "", lat = 0,lon=0){
		return {
			parents: [RaceTrack],
			_name		: name,
			_lat		: lat,
			_lon		: lon,
			_sectors	: [],
			_segments	: [[0,0,0]],
			_rotation 	: 0,
			_range		: 1.5,
		};
	},
	appendSector : func(sector){
		append(me._sectors,sector);
	},
	setRotation : func(deg){
		me._rotation = deg;
	},
	setRange : func(range){
		me._range = range;
	},	
	setData : func(data){
		me._segments = data;
	},
	drawSectors : func(parent){
		forindex(var i;me._sectors){
			me._sectors[i].drawSectorPoint(parent);
		}
	},
	
	drawTrackSegments : func(parent){
		var path = parent.createChild("path","Track")
				.setStrokeLineWidth(5)
				.setScale(1)
				.setColor(COLOR.Track);
		
		var cmd = canvas.Path.VG_MOVE_TO;
		var coords 	= [];
		var cmds	= [];
		
		forindex(var i;me._segments){
			append(coords,"N"~me._segments[i][1]);# lat
			append(coords,"E"~me._segments[i][0]);# lon
			append(cmds,cmd);
			cmd = canvas.Path.VG_LINE_TO;
		}
		append(cmds,canvas.Path.VG_CLOSE_PATH);
		path.setDataGeo(cmds,coords);
		path.setVisible(1);
		
	},
	
};
var RaceTrackSector = {
	new: func(name= "", lat = 0,lon=0,alt=0,transX=0,transY=0){
		var m = {
			parents: [RaceTrackSector],
			_name	: name,
			_lat	: lat,
			_lon	: lon,
			_alt	: alt,
			_translation : [transX,transY],
		};
		return m;
	},
	drawSectorPoint : func(parent){
		me._can = {
			point	: parent.createChild("group","SectorPoint"),
		};
		
		me._can.point.createChild("path", "icon")
			.setStrokeLineWidth(2)
			.setScale(1)
			.setColor(COLOR.Sector)
			.moveTo(-1, -1)
			.line(0, 2)
			.line(2, 0)
			.line(0, -2)
			.line(-2, 0);

		me._can.point.createChild("text", "text"~me._name)
			.setFont("LiberationFonts/LiberationMono-Bold.ttf")
			.setTranslation(me._translation[0],me._translation[1])
			.setFontSize(12, 1)
			.setColor(COLOR.Sector)
			.setColorFill(COLOR.Sector)
			.setAlignment("center-bottom-baseline" )
			.setText( me._name);
			
		me._can.point.setGeoPosition(me._lat,me._lon);
			
	}
	
};


var RaceMap = {
	new: func( title = "RoadRacer Map"){
		var m = {
			parents: [RaceMap],
			_title		: title,
			_dlg 		: nil,
			_canvas 	: nil,
			_map 		: nil,
			_otherBikes 	: {},
			_myBike 	: nil,
			_track 		: nil,
			_can 		: {},
			_timer 		: nil,
			_root		: nil,
			_isOpen		: 0,
		};
		
		m._timer = maketimer(0.25,m,RaceMap.update);
		m._nAIModels = props.globals.getNode("/ai/models");
		return m;
	},
	open : func (){
		if(!me._isOpen){
			me._dlg = canvas.Window.new([320,180], "dialog")
				.set("title", me._title)
				.set("resize", 1)
				.setPosition(20,50)
				;
			### overwriting dialog functions 
			me._dlg.parentObject = me;
			me._dlg.onResize = func()
			{
				if( me['_canvas'] == nil )
				return;

				for(var i = 0; i < 2; i += 1)
				{
					var size = me.get("content-size[" ~ i ~ "]");
					me._canvas.set("size[" ~ i ~ "]", size);
					me._canvas.set("view[" ~ i ~ "]", size);
				
				}
			
				var width = me.get("content-size[0]");
				var height = me.get("content-size[1]");
				me.parentObject._map.setTranslation(width/2,height/2);
			};
			me._dlg.del = func(){
				#print("my dialog::del() ...");
				me.parentObject.del();
				
				me.clearFocus();

				if( me["_canvas"] != nil )
				{
					var placements = me._canvas._node.getChildren("placement");
					# Do not remove canvas if other placements exist
					if( size(placements) > 1 )
						foreach(var p; placements)
						{
							if(p.getValue("type") == "window" and p.getValue("id") == me.get("id") )
								p.remove();
						}
					else
						me._canvas.del();
					me._canvas = nil;
				}
				if(me._node != nil){
					me._node.remove();
					me._node = nil;
				}
			};
			
			
			### creating the content canvas
			me._canvas = me._dlg.createCanvas();
			me._canvas.set("background", COLOR.Background);
			
			me._canvas.addEventListener("wheel", func(e) {
				me._map.adjustZoom(e.deltaY / 10); 
			});
			
			### creating the primary group
			me._root = me._canvas.createGroup();
			me._map = MyMap.new(me._root,"GeoMap");
			me._map.setTranslation(160,90); # half default screen size
			me._map.setRefPos(me._track._lat,me._track._lon);
			me._map.setHdg(me._track._rotation);
			me._map.setRangeNm(me._track._range);
			
			# some groups as layers on the map
			me._can = {
				grpRoad : me._map.createChild("group","road"),
				grpSectors : me._map.createChild("group","sectors"),
				grpBikes : me._map.createChild("group","bikes"),
			};
			#drawing the track
			me._track.drawSectors(me._can.grpSectors);
			me._track.drawTrackSegments(me._can.grpRoad);
			
			# add the ego bike
			var lat = getprop("/position/latitude-deg");
			var lon = getprop("/position/longitude-deg");
			
			me._myBike = SpriteBike.new(me._can.grpBikes,getprop("/sim/multiplay/callsign"));
			me._myBike.setGeoPosition(lat,lon);
			
				
			me._timer.start();
			me._isOpen = 1;
		}
		
	},
	del : func(){
		me._timer.stop();
		me._bikes = [];
		me._myBike = nil;
		me._can = {};
		me._map = nil;
		me._canvas = nil;
	},
	close : func(){
		me.del();
		me._dlg.del();
		me._isOpen = 0;

	},
	setRaceTrack :func(track){
		me._track = track;
		me._title = track._name;
		#me._dlg.set("title", me._title);
	},
	update : func(){
		var lat = getprop("/position/latitude-deg");
		var lon = getprop("/position/longitude-deg");
		
		me._myBike.setGeoPosition(lat,lon);
		
		foreach(var ac;me._nAIModels.getChildren("multiplayer")){
			var callsign    = ac.getChild("callsign").getValue();
			var lat 	= ac.getNode("position/latitude-deg").getValue();
			var lon 	= ac.getNode("position/longitude-deg").getValue();
			var transponderID 	= ac.getNode("instrumentation/transponder/transmitted-id").getValue();
			var id 	= ac.getNode("id").getValue();
			
			if (!contains(me._otherBikes,callsign)){
				me._otherBikes[callsign] = SpriteBike.new(me._can.grpBikes,callsign);
			}
			me._otherBikes[callsign].setGeoPosition(lat,lon);
			me._otherBikes[callsign].setVisible((transponderID == 26 and id >= 0));
		}
		
		
	}
};

############ Building the Tracks


var raceMap = RaceMap.new("RoadRacer Map");
var data = [];
var track = nil;




var open = func(){
	var nearestAirport = getprop("/sim/airport/closest-airport-id");
	var ownLat = getprop("/position/latitude-deg") or 0;
	
	if(nearestAirport == "EETN"){

		track = RaceTrack.new("Estonia - Kalevi Circuit",59.464166,24.847316);
		track.setRange(1.1);
		track.appendSector(RaceTrackSector.new("Start/Finish",59.45979784,24.84072284,27.0,-20,20));
		track.appendSector(RaceTrackSector.new("Kose Kurv",59.45863576,24.85181560,30.0,0,20));
		track.appendSector(RaceTrackSector.new("Klostrimetsa Kurv",59.46076939,24.86440203,24.0,5,20));
		track.appendSector(RaceTrackSector.new("Plangu Kurv",59.46632604,24.86785969,49.0,40,15));
		track.appendSector(RaceTrackSector.new("Uus Kurv",59.46737023,24.86866087,36.0,0,-10));
		track.appendSector(RaceTrackSector.new("Suur S",59.46826957,24.84336579,21.0,10,-10));
		track.appendSector(RaceTrackSector.new("Pirita Kurv",59.46823537,24.83455139,11.0,-45,0));
		track.appendSector(RaceTrackSector.new("Rummu Kurv",59.46316269,24.82727473,14.0,-20,20));

		data = [];
		append(data,[24.84057686 ,59.45981448 ,26.4009]);
		append(data,[24.85185658 ,59.45856912 ,30.4229]);
		append(data,[24.85226843 ,59.45935560 ,28.7363]);
		append(data,[24.85352113 ,59.46001523 ,20.8472]);
		append(data,[24.85395335 ,59.46045433 ,16.1495]);
		append(data,[24.85436006 ,59.46063829 ,13.8655]);
		append(data,[24.85872229 ,59.45995918 ,15.6506]);
		append(data,[24.86332368 ,59.46043017 ,20.3529]);
		append(data,[24.86464297 ,59.46091803 ,26.1049]);
		append(data,[24.86686662 ,59.46377225 ,35.2602]);
		append(data,[24.86708442 ,59.46479323 ,36.8631]);
		append(data,[24.86711330 ,59.46584507 ,37.6372]);
		append(data,[24.86761593 ,59.46626075 ,38.3014]);
		append(data,[24.86869363 ,59.46659925 ,38.5100]);
		append(data,[24.86911112 ,59.46689927 ,38.2761]);
		append(data,[24.86902270 ,59.46719451 ,37.2846]);
		append(data,[24.86817672 ,59.46744092 ,36.1058]);
		append(data,[24.86372113 ,59.46727029 ,33.9571]);
		append(data,[24.85866314 ,59.46636753 ,35.0051]);
		append(data,[24.85648593 ,59.46630058 ,34.2553]);
		append(data,[24.85378093 ,59.46653072 ,32.3577]);
		append(data,[24.84920763 ,59.46750222 ,29.2673]);
		append(data,[24.84641718 ,59.46781232 ,28.7092]);
		append(data,[24.84435256 ,59.46787982 ,23.5294]);
		append(data,[24.84333264 ,59.46826864 ,21.3405]);
		append(data,[24.84274640 ,59.46862459 ,20.0854]);
		append(data,[24.84203387 ,59.46870879 ,16.6274]);
		append(data,[24.83427032 ,59.46821555 ,11.2202]);
		append(data,[24.83330425 ,59.46659176 ,11.3046]);
		append(data,[24.82723055 ,59.46321299 ,14.1207]);
		append(data,[24.83057472 ,59.46243064 ,14.3994]);
		append(data,[24.83197359 ,59.46191343 ,16.1623]);
		append(data,[24.83306461 ,59.46129534 ,18.7843]);
		append(data,[24.83475373 ,59.46068981 ,22.8565]);
		append(data,[24.83611313 ,59.46034383 ,24.9153]);

		track.setData(data);

	}
############################
	elsif(nearestAirport == "NZWU"){
		track = RaceTrack.new("New Zealand - Wanganui - Cimetery Circuit",-39.938369,175.049377);
		track.setRange(0.35);
		
		track.appendSector(RaceTrackSector.new("Start/Finish",-39.93776583,175.05011601,9.0,-50,0));
		track.appendSector(RaceTrackSector.new("Mars Petcare Turn",-39.93673241,175.05110065,9.0,0,-10));
		track.appendSector(RaceTrackSector.new("Bridstone Corner",-39.93752452,175.05256072,4.0,60,15));
		track.appendSector(RaceTrackSector.new("Suzuki Crossing",-39.93948997,175.05067960,4.0,65,5));
		track.appendSector(RaceTrackSector.new("Heads Road",-39.93978927,175.04952614,7.0,45,10));
		track.appendSector(RaceTrackSector.new("Robert Holden",-39.94009814,175.04604448,12.0,0,15));
		track.appendSector(RaceTrackSector.new("Total Span Corner",-39.93889702,175.04581769,15.0,0,-15));

		data = [];
		append(data,[175.05111959 ,-39.93670827, 8.9810]);
		append(data,[175.05256366 ,-39.93749099, 3.9840]);
		append(data,[175.05078661 ,-39.93944934, 6.0573]);
		append(data,[175.05028689 ,-39.93945374, 7.0591]);
		append(data,[175.04901987 ,-39.93996809, 7.0009]);
		append(data,[175.04821686 ,-39.93981479, 8.5179]);
		append(data,[175.04607978 ,-39.94011560, 12.2159]);
		append(data,[175.04578281 ,-39.93887929, 15.0164]);
		append(data,[175.04711008 ,-39.93879434, 14.9050]);
		append(data,[175.04857307 ,-39.93906044, 14.9032]);
		append(data,[175.04900331 ,-39.93892257, 14.1889]);
		track.setData(data);
	}
#############################
	elsif(nearestAirport == "NZPM"){
		
		track = RaceTrack.new("New Zealand - Manfeild",-40.2368525,175.5577914);
		track.setRotation(30);
		track.setRange(0.3);
		
		track.appendSector(RaceTrackSector.new("Start/Finish",-40.23589635,175.55854994,20,40,-10));
		track.appendSector(RaceTrackSector.new("Turn 1",-40.23799392,175.56190470,15.0,-35,3));
		track.appendSector(RaceTrackSector.new("Turn 2",-40.23586105,175.55557602,15.0,35,8));
		track.appendSector(RaceTrackSector.new("Higgins",-40.23904496,175.56072339,15.0,-25,15));
		track.appendSector(RaceTrackSector.new("Turn 4",-40.23500935,175.55514906,15.0,-25,-10));


		data = [];
		append(data,[175.55854994,-40.23589635,64.1409]);
		append(data,[175.56172487,-40.23744520,64.1473]);
		append(data,[175.56200453,-40.23778510,64.1486]);
		append(data,[175.56190470,-40.23799392,64.1482]);
		append(data,[175.56149383,-40.23810041,64.1464]);
		append(data,[175.56054750,-40.23804744,64.1426]);
		append(data,[175.55956141,-40.23782961,64.1397]);
		append(data,[175.55891799,-40.23730654,64.1385]);
		append(data,[175.55873164,-40.23686820,64.1388]);
		append(data,[175.55866416,-40.23653877,64.1393]);
		append(data,[175.55848436,-40.23628428,64.1397]);
		append(data,[175.55816505,-40.23619107,64.1397]);
		append(data,[175.55749815,-40.23629410,64.1392]);
		append(data,[175.55714969,-40.23629788,64.1393]);
		append(data,[175.55686419,-40.23622319,64.1396]);
		append(data,[175.55626338,-40.23589146,64.1413]);
		append(data,[175.55585420,-40.23576427,64.1425]);
		append(data,[175.55557602,-40.23576007,64.1431]);
		append(data,[175.55541755,-40.23586105,64.1431]);
		append(data,[175.55544021,-40.23607055,64.1423]);
		append(data,[175.55620003,-40.23671222,64.1393]);
		append(data,[175.56043140,-40.23878223,64.1433]);
		append(data,[175.56072339,-40.23904496,64.1449]);
		append(data,[175.56072574,-40.23933827,64.1458]);
		append(data,[175.56040761,-40.23949917,64.1453]);
		append(data,[175.55952619,-40.23947515,64.1428]);
		append(data,[175.55876913,-40.23917415,64.1404]);
		append(data,[175.55815410,-40.23881456,64.1389]);
		append(data,[175.55498552,-40.23622648,64.1431]);
		append(data,[175.55478627,-40.23580713,64.1450]);
		append(data,[175.55479289,-40.23536023,64.1468]);
		append(data,[175.55514906,-40.23500935,64.1474]);
		append(data,[175.55562625,-40.23498026,64.1464]);
		append(data,[175.55738997,-40.23534693,64.1426]);

		track.setData(data);
	}
#############################
	elsif(nearestAirport == "NZME"){
		
		track = RaceTrack.new("New Zealand - Hampton Downs",-37.354743,175.076479);
		track.setRotation(90);
		track.setRange(0.35);
		
		track.appendSector(RaceTrackSector.new("Start/Finish",-37.35664293,175.07731681,20,40,-10));
		track.appendSector(RaceTrackSector.new("Turn 1",-37.35811939,175.07595680,15.0,-30,10));
		track.appendSector(RaceTrackSector.new("Turn 2",-37.35520934,175.07387098,15.0,-25,15));
		track.appendSector(RaceTrackSector.new("S-Bend",-37.35426269,175.07525481,15.0,-25,15));
		track.appendSector(RaceTrackSector.new("Turn 6",-37.35039383,175.07636167,15.0,-25,15));


		data = [];
		append(data,[175.07671215,-37.35764825,19.1602]);
		append(data,[175.07569250,-37.35811443,14.6567]);
		append(data,[175.07528152,-37.35778412,13.5503]);
		append(data,[175.07379277,-37.35570838,9.0439]);
		append(data,[175.07372073,-37.35546844,9.7296]);
		append(data,[175.07377535,-37.35531872,10.6163]);
		append(data,[175.07390277,-37.35520157,11.9403]);
		append(data,[175.07430787,-37.35516583,13.3921]);
		append(data,[175.07481460,-37.35511164,14.6945]);
		append(data,[175.07520610,-37.35475692,15.6692]);
		append(data,[175.07541453,-37.35291363,14.3513]);
		append(data,[175.07554398,-37.35281177,14.7999]);
		append(data,[175.07571485,-37.35282738,15.3735]);
		append(data,[175.07591707,-37.35294186,16.0956]);
		append(data,[175.07699249,-37.35488595,22.4651]);
		append(data,[175.07715120,-37.35498832,22.6058]);
		append(data,[175.07739356,-37.35497084,22.6631]);
		append(data,[175.07744702,-37.35482989,22.3032]);
		append(data,[175.07590597,-37.35091243,14.4970]);
		append(data,[175.07604267,-37.35059439,14.4988]);
		append(data,[175.07638990,-37.35039630,14.4994]);
		append(data,[175.07682445,-37.35033441,14.4989]);
		append(data,[175.07741219,-37.35053176,14.4966]);
		append(data,[175.07802762,-37.35177693,14.3867]);
		append(data,[175.07832163,-37.35408551,21.0330]);
		append(data,[175.07793642,-37.35557001,25.0501]);

		track.setData(data);
	}
###############################	
	elsif(nearestAirport == "VMMC"){
		
		track = RaceTrack.new("Macau - Grand Prix",22.197407,113.554673);

		track.appendSector(RaceTrackSector.new("Start/Finish",22.19920050,113.55963580,6.0,50,10));
		track.appendSector(RaceTrackSector.new("Reservoir",22.19828524,113.55742500,6.0,40,15));
		track.appendSector(RaceTrackSector.new("Mandarin",22.19229900,113.55264253,33.0,40,10));
		track.appendSector(RaceTrackSector.new("Lisboa",22.18959924,113.54543181,44.0,40,15));
		track.appendSector(RaceTrackSector.new("Maternity",22.19538612,113.54859076,45.0,-40,0));
		track.appendSector(RaceTrackSector.new("Solitude",22.19583960,113.55128517,43.0,-30,-10));
		track.appendSector(RaceTrackSector.new("Melco Hairpin",22.20395773,113.55417385,15.0,-60,5));
		track.appendSector(RaceTrackSector.new("Donna Maria",22.20357370,113.55682861,15.0,0,-15));
		track.appendSector(RaceTrackSector.new("Fishermens",22.20460693,113.56055762,6.0,50,5));
		


		data = [];
		append(data,[113.56165037,22.19954160,6.0718]);
		append(data,[113.55764784,22.19841387,6.4133]);
		append(data,[113.55717448,22.19805716,7.2891]);
		append(data,[113.55292353,22.19250267,32.2964]);
		append(data,[113.55254621,22.19225234,34.0467]);
		append(data,[113.54554959,22.18962478,44.9410]);
		append(data,[113.54533380,22.18971024,44.8497]);
		append(data,[113.54472411,22.19081387,44.8427]);
		append(data,[113.54475343,22.19100029,44.8427]);
		append(data,[113.54558106,22.19203901,42.8672]);
		append(data,[113.54642107,22.19278289,42.3786]);
		append(data,[113.54669843,22.19308695,42.5325]);
		append(data,[113.54736891,22.19405493,43.0695]);
		append(data,[113.54792176,22.19453228,43.0695]);
		append(data,[113.54848926,22.19479430,44.5656]);
		append(data,[113.54860138,22.19500355,44.7729]);
		append(data,[113.54861424,22.19556669,45.3595]);
		append(data,[113.54875877,22.19567350,45.3595]);
		append(data,[113.54971032,22.19545637,45.6566]);
		append(data,[113.55082162,22.19512788,43.4037]);
		append(data,[113.55105749,22.19519690,43.4037]);
		append(data,[113.55121089,22.19546264,43.3699]);
		append(data,[113.55137521,22.19626804,42.6584]);
		append(data,[113.55173344,22.19671170,42.0165]);
		append(data,[113.55228028,22.19687090,41.2771]);
		append(data,[113.55266856,22.19710682,40.3679]);
		append(data,[113.55313008,22.19774100,38.5596]);
		append(data,[113.55352244,22.19806662,37.2393]);
		append(data,[113.55436787,22.19855564,34.2339]);
		append(data,[113.55447910,22.19878072,33.6198]);
		append(data,[113.55432951,22.19909444,33.3819]);
		append(data,[113.55430755,22.19932558,32.8807]);
		append(data,[113.55450034,22.19982919,30.7429]);
		append(data,[113.55453199,22.20034299,28.5736]);
		append(data,[113.55424813,22.20096039,25.3287]);
		append(data,[113.55379944,22.20156400,21.2066]);
		append(data,[113.55369617,22.20196052,18.1726]);
		append(data,[113.55419220,22.20305543,15.5716]);
		append(data,[113.55542556,22.20295239,15.5717]);
		append(data,[113.55602312,22.20304468,15.5716]);
		append(data,[113.55630593,22.20317007,15.5716]);
		append(data,[113.55676470,22.20346152,15.5716]);
		append(data,[113.55683761,22.20361616,15.5716]);
		append(data,[113.55677235,22.20377313,15.5716]);
		append(data,[113.55657760,22.20384136,15.5716]);
		append(data,[113.55600663,22.20389187,15.5716]);
		append(data,[113.55511634,22.20383622,15.5716]);
		append(data,[113.55430188,22.20389228,15.4077]);
		append(data,[113.55415749,22.20395813,15.0321]);
		append(data,[113.55433243,22.20400247,13.8399]);
		append(data,[113.55468035,22.20396141,10.8467]);
		append(data,[113.55491177,22.20398610,8.7991]);
		append(data,[113.55557981,22.20422131,6.1478]);
		append(data,[113.55604954,22.20425935,6.0716]);
		append(data,[113.55674654,22.20425737,6.0716]);
		append(data,[113.55816758,22.20447397,6.0717]);
		append(data,[113.56011990,22.20474618,6.0718]);
		append(data,[113.56054571,22.20461672,6.0716]);
		append(data,[113.56081509,22.20413064,6.0716]);
		append(data,[113.56207658,22.20028416,6.0717]);
		append(data,[113.56208704,22.20000193,6.0716]);
		append(data,[113.56192823,22.19971329,6.0716]);

		track.setData(data);
	}
###############################
	elsif(nearestAirport == "EGAA"){
		
		track = RaceTrack.new("Northern Ireland - Ulster GP",54.595521,-6.092870);
		track.setRange(2.4);
		track.appendSector(RaceTrackSector.new("Grandstand",54.58127383,-6.08652248,233,15,15));
		track.appendSector(RaceTrackSector.new("Rusheyhill",54.58278197,-6.09298049,221.0,-40,10));
		track.appendSector(RaceTrackSector.new("Leathemstown",54.58621098,-6.11346216,183.0,-50,0));
		track.appendSector(RaceTrackSector.new("Deers  Leap",54.59629911,-6.12266692,201.0,-4,5));
		track.appendSector(RaceTrackSector.new("Cochranstown",54.60489992,-6.12189404,148.0,-30,-8));
		track.appendSector(RaceTrackSector.new("Quaterlands",54.60847208,-6.11141598,167.0,0,-10));
		track.appendSector(RaceTrackSector.new("Irelands",54.60785164,-6.10735275,166.0,25,15));
		track.appendSector(RaceTrackSector.new("Joeys Windmill",54.60680269,-6.08422385,220.0,55,0));
		track.appendSector(RaceTrackSector.new("Wheelers  Corner",54.59776912,-6.06810641,296.0,-8,2));
		track.appendSector(RaceTrackSector.new("Lindsay",54.59186171,-6.06029854,279.0,30,-10));
		track.appendSector(RaceTrackSector.new("Hairpin",54.59186171,-6.06029854,279.0,30, 0));
		track.appendSector(RaceTrackSector.new("The  Quarries",54.58593594,-6.06833188,281.0,17,5));
		
		data = [];
		append(data,[-6.08181555,54.58055961,240.8119]);
		append(data,[-6.08832315,54.58162244,231.8891]);
		append(data,[-6.09829917,54.58410484,212.2166]);
		append(data,[-6.09988959,54.58439389,210.4150]);
		append(data,[-6.10137826,54.58447460,208.7563]);
		append(data,[-6.10321165,54.58442476,206.5060]);
		append(data,[-6.10440159,54.58457729,203.8941]);
		append(data,[-6.10751157,54.58563194,195.6195]);
		append(data,[-6.10864872,54.58593811,194.5054]);
		append(data,[-6.10948199,54.58605004,192.5772]);
		append(data,[-6.11210836,54.58610702,185.8908]);
		append(data,[-6.11347726,54.58620420,183.4060]);
		append(data,[-6.11911532,54.59181636,187.3927]);
		append(data,[-6.12140452,54.59430461,200.1797]);
		append(data,[-6.12195610,54.59507912,201.1374]);
		append(data,[-6.12269461,54.59632531,201.3289]);
		append(data,[-6.12279300,54.59698857,200.0382]);
		append(data,[-6.12238644,54.60348380,157.5855]);
		append(data,[-6.12214159,54.60433280,152.5106]);
		append(data,[-6.12191686,54.60485919,148.6024]);
		append(data,[-6.12167780,54.60501906,147.5742]);
		append(data,[-6.11984358,54.60561750,147.2651]);
		append(data,[-6.11722459,54.60656706,153.5311]);
		append(data,[-6.11512906,54.60742284,163.8672]);
		append(data,[-6.11259909,54.60825419,164.9275]);
		append(data,[-6.11168988,54.60845703,166.8681]);
		append(data,[-6.11126654,54.60843865,167.6323]);
		append(data,[-6.10817315,54.60783772,167.3877]);
		append(data,[-6.10755893,54.60782870,166.9939]);
		append(data,[-6.10609893,54.60809223,165.3322]);
		append(data,[-6.10416032,54.60850154,166.0820]);
		append(data,[-6.10150669,54.60880004,173.8053]);
		append(data,[-6.09842190,54.60920325,179.6997]);
		append(data,[-6.09411263,54.60945485,192.9916]);
		append(data,[-6.09332667,54.60940032,196.9190]);
		append(data,[-6.09204793,54.60918382,200.9795]);
		append(data,[-6.09116403,54.60891653,201.7062]);
		append(data,[-6.08807477,54.60785815,207.2235]);
		append(data,[-6.08593022,54.60722688,213.0670]);
		append(data,[-6.08456190,54.60691571,218.3106]);
		append(data,[-6.08407144,54.60674132,220.9844]);
		append(data,[-6.08252314,54.60562135,226.7006]);
		append(data,[-6.08033960,54.60426815,239.8716]);
		append(data,[-6.07782360,54.60294058,256.9436]);
		append(data,[-6.07632293,54.60238352,267.3772]);
		append(data,[-6.07329032,54.60112119,279.8070]);
		append(data,[-6.07015944,54.59894029,289.5787]);
		append(data,[-6.06944394,54.59850807,290.3545]);
		append(data,[-6.06839050,54.59798235,295.4705]);
		append(data,[-6.06797700,54.59750416,296.0849]);
		append(data,[-6.06677038,54.59286426,292.9355]);
		append(data,[-6.06660744,54.59192149,295.3260]);
		append(data,[-6.06611481,54.59149537,295.3259]);
		append(data,[-6.06508546,54.59123573,293.3642]);
		append(data,[-6.06420096,54.59091735,290.5313]);
		append(data,[-6.06307778,54.59086050,286.6575]);
		append(data,[-6.06064518,54.59184458,280.1308]);
		append(data,[-6.06032945,54.59189771,279.5615]);
		append(data,[-6.06022274,54.59178858,278.1694]);
		append(data,[-6.06033541,54.59157913,277.1535]);
		append(data,[-6.06071037,54.59141114,278.4916]);
		append(data,[-6.06144904,54.59103391,279.4876]);
		append(data,[-6.06201735,54.59055571,280.1391]);
		append(data,[-6.06260046,54.59015016,280.3444]);
		append(data,[-6.06329356,54.58971840,282.1533]);
		append(data,[-6.06383534,54.58928728,283.3478]);
		append(data,[-6.06512021,54.58791297,284.3572]);
		append(data,[-6.06578436,54.58742918,284.9576]);
		append(data,[-6.06736263,54.58679790,285.9283]);
		append(data,[-6.06804703,54.58633969,283.9242]);
		append(data,[-6.06937129,54.58454287,277.8536]);
		append(data,[-6.07034867,54.58362149,274.6974]);
		append(data,[-6.07130761,54.58307601,273.6567]);
		append(data,[-6.07208146,54.58284011,273.5565]);
		append(data,[-6.07420514,54.58265472,268.5725]);
		append(data,[-6.07489757,54.58252241,265.8903]);
		append(data,[-6.07551163,54.58226266,263.0899]);
		append(data,[-6.07744740,54.58090835,253.7710]);
		append(data,[-6.07836445,54.58056143,251.6164]);
		append(data,[-6.07902971,54.58048953,249.9319]);
		append(data,[-6.07994642,54.58044219,246.7606]);
		append(data,[-6.08079689,54.58045472,243.7262]);


		track.setData(data);
	}
###############################
	elsif((nearestAirport == "EGAE") or (nearestAirport == "EG05") or (nearestAirport == "XMUL") ){
		
		track = RaceTrack.new("Northern Ireland - North West 200",55.180769,-6.674545);
		track.setRange(3.8);
		
		track.appendSector(RaceTrackSector.new("Start/Finish",55.19291196,-6.69767340,13,-20,-10));
		track.appendSector(RaceTrackSector.new("York Corner",55.18822340,-6.71147187,8,-45,0));
		track.appendSector(RaceTrackSector.new("Mill Road",55.18469372,-6.70330934,30,30,-5));
		track.appendSector(RaceTrackSector.new("Black Bridge",55.17787917,-6.68826330,30,-50,5));
		track.appendSector(RaceTrackSector.new("University",55.15612365,-6.67232409,20,-45,0));
		track.appendSector(RaceTrackSector.new("Ballysally",55.15706229,-6.66395081,40,45,0));
		track.appendSector(RaceTrackSector.new("Mathers Cross",55.17036041,-6.66479688,20,55,0));
		track.appendSector(RaceTrackSector.new("Carnalridge",55.18521607,-6.65802740,34,45,0));
		track.appendSector(RaceTrackSector.new("Metropole",55.19879913,-6.65528507,8,40,-5));
		track.appendSector(RaceTrackSector.new("Black Hill",55.19844856,-6.66710891,27,-20,-6));
		
		data = [];
		append(data,[-6.69776221,55.19288189,13.3035]);
		append(data,[-6.70115914,55.19178676,12.7312]);
		append(data,[-6.70213280,55.19164885,11.5721]);
		append(data,[-6.70428691,55.19175545,10.0390]);
		append(data,[-6.70548723,55.19166174,9.9557]);
		append(data,[-6.70657553,55.19122477,10.7742]);
		append(data,[-6.70722593,55.19070372,11.3613]);
		append(data,[-6.70816508,55.19013696,11.2737]);
		append(data,[-6.70880698,55.18962238,10.3297]);
		append(data,[-6.70966751,55.18902668,8.1482]);
		append(data,[-6.71160694,55.18819897,8.1482]);
		append(data,[-6.71139794,55.18809254,9.0176]);
		append(data,[-6.70993954,55.18792148,12.6158]);
		append(data,[-6.70914905,55.18765700,15.3539]);
		append(data,[-6.70384452,55.18496594,30.4861]);
		append(data,[-6.70369966,55.18474693,31.6020]);
		append(data,[-6.70331689,55.18456688,32.3455]);
		append(data,[-6.70286037,55.18482903,30.4729]);
		append(data,[-6.69913774,55.18394878,32.1470]);
		append(data,[-6.69812981,55.18355116,32.1236]);
		append(data,[-6.68884363,55.17830229,29.2278]);
		append(data,[-6.68800432,55.17767032,29.8295]);
		append(data,[-6.68520151,55.17419250,29.9690]);
		append(data,[-6.68325317,55.17217673,30.8720]);
		append(data,[-6.68185344,55.17051901,33.8469]);
		append(data,[-6.67924380,55.16723480,28.2655]);
		append(data,[-6.67693237,55.16458894,28.3275]);
		append(data,[-6.67437106,55.16034850,27.7683]);
		append(data,[-6.67379528,55.15907865,27.5784]);
		append(data,[-6.67229061,55.15608282,20.4179]);
		append(data,[-6.67051028,55.15636548,29.0207]);
		append(data,[-6.66870020,55.15648158,25.5897]);
		append(data,[-6.66562611,55.15622525,27.3466]);
		append(data,[-6.66502378,55.15598746,27.3461]);
		append(data,[-6.66454656,55.15570630,27.3384]);
		append(data,[-6.66410642,55.15563118,27.3384]);
		append(data,[-6.66355650,55.15578011,27.3384]);
		append(data,[-6.66339108,55.15619766,27.3384]);
		append(data,[-6.66371891,55.15644043,27.3384]);
		append(data,[-6.66399358,55.15691664,29.6685]);
		append(data,[-6.66337012,55.15877985,32.9751]);
		append(data,[-6.66330826,55.15927844,33.5577]);
		append(data,[-6.66480246,55.17013916,39.6814]);
		append(data,[-6.66462007,55.17023723,39.8795]);
		append(data,[-6.66460948,55.17040075,40.2288]);
		append(data,[-6.66483475,55.17055638,40.5741]);
		append(data,[-6.66478595,55.17099468,41.5365]);
		append(data,[-6.66448476,55.17169945,42.2190]);
		append(data,[-6.65989260,55.17979062,44.1745]);
		append(data,[-6.65911444,55.18133421,40.3992]);
		append(data,[-6.65801898,55.18502017,34.8708]);
		append(data,[-6.65817869,55.18514350,34.8695]);
		append(data,[-6.65815043,55.18532155,34.8695]);
		append(data,[-6.65790708,55.18542995,34.8708]);
		append(data,[-6.65420823,55.19873868,9.3886]);
		append(data,[-6.65427778,55.19894790,9.6121]);
		append(data,[-6.65521354,55.19883196,8.1965]);
		append(data,[-6.65599861,55.19837027,6.6223]);
		append(data,[-6.65671415,55.19741143,7.0964]);
		append(data,[-6.65762436,55.19689246,9.4896]);
		append(data,[-6.65917976,55.19681827,14.2627]);
		append(data,[-6.65967105,55.19690910,15.7615]);
		append(data,[-6.66159764,55.19694114,20.0704]);
		append(data,[-6.66245722,55.19711588,22.6960]);
		append(data,[-6.66559905,55.19812501,27.1538]);
		append(data,[-6.66677008,55.19841354,27.9216]);
		append(data,[-6.66804233,55.19832286,27.9216]);
		append(data,[-6.66879757,55.19816352,25.8111]);
		append(data,[-6.66960355,55.19814290,23.5955]);
		append(data,[-6.67046847,55.19814458,21.7382]);
		append(data,[-6.67163788,55.19803553,19.4695]);
		append(data,[-6.67366209,55.19769929,20.5964]);
		append(data,[-6.67616501,55.19691553,22.9251]);
		append(data,[-6.67690008,55.19674035,23.8982]);
		append(data,[-6.67867333,55.19640570,24.5190]);
		append(data,[-6.67892636,55.19624164,24.2640]);
		append(data,[-6.67952533,55.19612801,23.7731]);
		append(data,[-6.67979727,55.19620617,23.6033]);
		append(data,[-6.68204358,55.19574877,21.1475]);
		append(data,[-6.68326966,55.19534092,19.7573]);
		append(data,[-6.68564047,55.19441970,19.3797]);
		append(data,[-6.68738750,55.19401014,19.5563]);
		append(data,[-6.68870523,55.19395158,20.9740]);
		append(data,[-6.68990925,55.19416624,23.3560]);
		append(data,[-6.69134603,55.19449401,24.8997]);
		append(data,[-6.69307482,55.19439508,23.1748]);
		append(data,[-6.69381491,55.19379386,21.6498]);
		append(data,[-6.69700048,55.19271113,15.2606]);


		track.setData(data);
	}
###############################
	elsif(nearestAirport == "EGNS" and ownLat > 54.135){
		
		track = RaceTrack.new("Isle of Man - Tourist Trophy",54.252358,-4.519594);

		track.setRange(13.7);

		track.appendSector(RaceTrackSector.new("Grandstand",54.16670804,-4.48068530,79,44,0));
		track.appendSector(RaceTrackSector.new("Bray Hill",54.16216663,-4.48926178,40,35,10));
		track.appendSector(RaceTrackSector.new("Braddan Bridge",54.16125282,-4.50528018,23,-45,10));
		track.appendSector(RaceTrackSector.new("Ballagarey",54.17412218,-4.54970452,62,-40,7));
		track.appendSector(RaceTrackSector.new("Greeba Castle",54.19368006,-4.59572967,63,-50,10));
		track.appendSector(RaceTrackSector.new("Ballacraine",54.20269392,-4.62903932,52,-50,0));
		track.appendSector(RaceTrackSector.new("Glen Helen",54.22020313,-4.62823605,103,-44,0));
		track.appendSector(RaceTrackSector.new("Cronk-y-Voddy",54.24185667,-4.60577743,182,-55,5));
		track.appendSector(RaceTrackSector.new("Barregarrow",54.26554833,-4.57961631,93,-45,3));
		track.appendSector(RaceTrackSector.new("Kirk Michael",54.28095285,-4.58787272,47,-50,0));
		track.appendSector(RaceTrackSector.new("Rhencullen",54.29437309,-4.57583065,37,-40,0));
		track.appendSector(RaceTrackSector.new("Ballaugh Bri.",54.30997575,-4.54054979,34,-50,0));
		track.appendSector(RaceTrackSector.new("Sulby Bri.",54.31838687,-4.43103875,26,-70,-3));
		track.appendSector(RaceTrackSector.new("Glen Duff",54.32280476,-4.47283132,16,0,-10));
		track.appendSector(RaceTrackSector.new("Ramsey Hair.",54.31322202,-4.38423172,71,50,-5));
		track.appendSector(RaceTrackSector.new("Joeys",54.30108723,-4.39367583,254,30,5));
		track.appendSector(RaceTrackSector.new("Mountain Mile",54.29031519,-4.41531116,359,53,7));
		track.appendSector(RaceTrackSector.new("Verandah",54.26296698,-4.44874921,420,40,0));
		track.appendSector(RaceTrackSector.new("Bungalow",54.25029998,-4.46338492,412,40,5));
		track.appendSector(RaceTrackSector.new("Windy Corner",54.23040380,-4.47017563,371,50,0));
		track.appendSector(RaceTrackSector.new("Kate's Cott.",54.21349595,-4.47938291,321,50,0));
		track.appendSector(RaceTrackSector.new("Cronk'ny'Mo.",54.18736723,-4.47447412,118,55,0));


		data = [];
		
		append(data,[-4.47617360,54.16877005,86.0841]); # start
		append(data,[-4.48200423,54.16604483,76.9540]);
		append(data,[-4.48333125,54.16552529,73.3926]);
		append(data,[-4.48405855,54.16517710,71.1332]);
		append(data,[-4.48569539,54.16416852,66.1987]);
		append(data,[-4.48793330,54.16303884,53.9147]);
		append(data,[-4.49011279,54.16148729,34.6571]);
		append(data,[-4.49636925,54.15848654,44.1341]);
		append(data,[-4.49923650,54.15715461,32.0749]);
		append(data,[-4.50107931,54.15578729,19.5025]);
		append(data,[-4.50174650,54.15598487,18.0871]);
		append(data,[-4.50463281,54.16102276,23.9245]);
		append(data,[-4.50517399,54.16126496,23.9441]);
		append(data,[-4.50579643,54.16131693,24.7405]);
		append(data,[-4.50653011,54.16160169,26.3397]);
		append(data,[-4.50844846,54.16296825,28.7639]);
		append(data,[-4.51198170,54.16510425,32.6477]);
		append(data,[-4.51399552,54.16617669,34.4389]);
		append(data,[-4.51950618,54.16813474,40.4211]);
		append(data,[-4.52159034,54.16864613,37.7028]);
		append(data,[-4.52339654,54.16968512,32.3612]);
		append(data,[-4.52508267,54.17012062,29.5994]);
		append(data,[-4.53934165,54.17194149,62.0781]);
		append(data,[-4.54224687,54.17248407,69.9857]);
		append(data,[-4.54868638,54.17380087,62.8686]);
		append(data,[-4.55016231,54.17435676,62.1947]);
		append(data,[-4.56043492,54.18125249,50.1627]);
		append(data,[-4.56142421,54.18183313,47.2593]);
		append(data,[-4.56407796,54.18285771,48.5784]);
		append(data,[-4.56764779,54.18457400,54.1187]);
		append(data,[-4.57279214,54.18667272,69.2663]);
		append(data,[-4.58279403,54.19065890,54.1990]);
		append(data,[-4.58516817,54.19191604,64.1707]);
		append(data,[-4.58833753,54.19266843,65.9105]);
		append(data,[-4.59138684,54.19278537,62.1445]);
		append(data,[-4.59661388,54.19380421,63.1140]);
		append(data,[-4.59870821,54.19384030,57.8294]);
		append(data,[-4.60158813,54.19466335,55.9405]);
		append(data,[-4.60509430,54.19647932,60.9072]);
		append(data,[-4.60634478,54.19689578,59.4286]);
		append(data,[-4.61436882,54.19747382,55.1051]);
		append(data,[-4.61816908,54.19815539,53.6606]);
		append(data,[-4.62003183,54.19887198,52.7973]);
		append(data,[-4.62914447,54.20275912,53.1589]);
		append(data,[-4.62949592,54.20549252,69.9866]);
		append(data,[-4.63048692,54.20690892,68.1582]);
		append(data,[-4.63058707,54.20868809,67.5168]);
		append(data,[-4.63019050,54.21112295,69.8990]);
		append(data,[-4.63056697,54.21228370,70.5718]);
		append(data,[-4.63230866,54.21397080,76.9773]);
		append(data,[-4.63311053,54.21526849,85.5110]);
		append(data,[-4.63297754,54.21574956,86.5625]);
		append(data,[-4.63261008,54.21629353,85.7773]);
		append(data,[-4.63258290,54.21683092,85.5761]);
		append(data,[-4.63291860,54.21777867,90.8833]);
		append(data,[-4.63217292,54.21863340,91.6241]);
		append(data,[-4.63055104,54.21915459,93.9818]);
		append(data,[-4.62838885,54.22015630,104.0271]);
		append(data,[-4.62622594,54.22097287,100.5113]);
		append(data,[-4.62570305,54.22148235,101.1797]);
		append(data,[-4.62482199,54.22199173,101.1797]);
		append(data,[-4.61975500,54.22308708,108.2812]);
		append(data,[-4.61810111,54.22404631,108.6928]);
		append(data,[-4.61716564,54.22596969,119.0274]);
		append(data,[-4.61758260,54.22662244,128.7530]);
		append(data,[-4.61953642,54.22768476,132.5042]);
		append(data,[-4.61933381,54.22906191,133.1963]);
		append(data,[-4.61858460,54.23016191,138.1038]);
		append(data,[-4.61749754,54.23079835,144.1345]);
		append(data,[-4.61324737,54.23572289,172.6759]);
		append(data,[-4.60625558,54.24162893,182.8765]);
		append(data,[-4.60127185,54.24426352,168.2591]);
		append(data,[-4.59700226,54.24521393,166.8757]);
		append(data,[-4.59437744,54.24619606,163.0064]);
		append(data,[-4.58179482,54.26024426,130.6442]);
		append(data,[-4.58123088,54.26101213,128.6647]);
		append(data,[-4.57964403,54.26549325,93.9624]);
		append(data,[-4.58030324,54.27180519,86.5737]);
		append(data,[-4.58019410,54.27250120,84.8670]);
		append(data,[-4.57934626,54.27453583,74.2275]);
		append(data,[-4.57951521,54.27519413,73.7451]);
		append(data,[-4.58743646,54.28055923,49.3364]);
		append(data,[-4.58796713,54.28104974,46.7990]);
		append(data,[-4.58786472,54.28268144,41.8183]);
		append(data,[-4.58667252,54.28426636,36.8040]);
		append(data,[-4.58047725,54.28901242,37.8149]);
		append(data,[-4.57770165,54.29295979,37.7581]);
		append(data,[-4.57621370,54.29390861,37.8532]);
		append(data,[-4.57390241,54.29691943,30.7381]);
		append(data,[-4.56742849,54.30155411,38.4960]);
		append(data,[-4.55721860,54.30619017,32.0632]);
		append(data,[-4.54275400,54.30936918,33.3464]);
		append(data,[-4.54177484,54.30957329,34.3736]);
		append(data,[-4.54121431,54.30983396,34.9102]);
		append(data,[-4.54055696,54.30998720,35.5034]);
		append(data,[-4.53985467,54.31001475,35.8714]);
		append(data,[-4.53855238,54.31036712,34.1931]);
		append(data,[-4.53689454,54.31089974,31.9203]);
		append(data,[-4.53504819,54.31120046,29.8081]);
		append(data,[-4.52782203,54.31190974,26.4468]);
		append(data,[-4.52591445,54.31232100,27.6751]);
		append(data,[-4.52017330,54.31417534,25.0808]);
		append(data,[-4.51206503,54.31593135,21.3439]);
		append(data,[-4.50841751,54.31608865,34.3768]);
		append(data,[-4.50630436,54.31663922,37.5374]);
		append(data,[-4.50441108,54.31698931,36.8467]);
		append(data,[-4.50265024,54.31749548,30.0442]);
		append(data,[-4.49621496,54.31846287,22.5349]);
		append(data,[-4.48009630,54.32224359,18.4161]);
		append(data,[-4.47348564,54.32302926,15.7297]);
		append(data,[-4.47288197,54.32291896,16.0129]);
		append(data,[-4.47184103,54.32174277,15.9161]);
		append(data,[-4.47048038,54.32105531,21.9347]);
		append(data,[-4.46826505,54.32096772,29.7543]);
		append(data,[-4.46599902,54.32125663,33.7209]);
		append(data,[-4.46324539,54.32113058,25.0564]);
		append(data,[-4.46068552,54.32150451,22.8708]);
		append(data,[-4.45701631,54.32142275,26.7636]);
		append(data,[-4.44664035,54.32005645,24.4803]);
		append(data,[-4.43974335,54.31876086,25.6137]);
		append(data,[-4.43510893,54.31868588,29.4050]);
		append(data,[-4.43371390,54.31826213,27.1208]);
		append(data,[-4.43236071,54.31811693,24.6259]);
		append(data,[-4.42950148,54.31872899,23.6798]);
		append(data,[-4.42482327,54.31914363,24.3789]);
		append(data,[-4.42290740,54.31920062,24.7051]);
		append(data,[-4.41609331,54.32041705,27.2531]);
		append(data,[-4.41342524,54.32052044,26.8485]);
		append(data,[-4.41074876,54.32095137,16.7911]);
		append(data,[-4.40361213,54.32133833,18.0121]);
		append(data,[-4.39410177,54.32063730,9.2353]);
		append(data,[-4.39340835,54.32064393,9.0898]);
		append(data,[-4.38695417,54.32212773,7.0552]);
		append(data,[-4.38645812,54.32203150,7.0551]);
		append(data,[-4.38603471,54.32141020,7.0553]);
		append(data,[-4.38282051,54.31961505,9.9417]);
		append(data,[-4.38256520,54.31919843,14.5943]);
		append(data,[-4.38360341,54.31719412,27.3670]);
		append(data,[-4.38365203,54.31670145,27.9403]);
		append(data,[-4.38314735,54.31565711,29.1121]);
		append(data,[-4.38294244,54.31482483,37.9591]);
		append(data,[-4.38350822,54.31411324,47.8636]);
		append(data,[-4.38511106,54.31314034,63.9975]);
		append(data,[-4.38514734,54.31302955,65.7147]);
		append(data,[-4.38492030,54.31291599,68.8622]);
		append(data,[-4.38399779,54.31331397,72.6359]);
		append(data,[-4.38151402,54.31386691,81.7919]);
		append(data,[-4.37748910,54.31359789,93.8064]);
		append(data,[-4.37647044,54.31309519,95.1252]);
		append(data,[-4.37627396,54.31279550,97.2396]);
		append(data,[-4.37883699,54.31092723,123.8216]);
		append(data,[-4.37998882,54.30993508,130.5388]);
		append(data,[-4.38182180,54.30698286,158.7037]);
		append(data,[-4.38193127,54.30640380,162.8286]);
		append(data,[-4.38152890,54.30551904,170.1328]);
		append(data,[-4.38154115,54.30532174,172.3727]);
		append(data,[-4.38170129,54.30523685,173.8638]);
		append(data,[-4.38225764,54.30527875,176.5174]);
		append(data,[-4.38339421,54.30533661,183.2230]);
		append(data,[-4.38711780,54.30505531,200.3428]);
		append(data,[-4.39038866,54.30402946,220.5785]);
		append(data,[-4.39379539,54.30098726,255.6302]);
		append(data,[-4.40215905,54.29784852,296.5982]);
		append(data,[-4.40392789,54.29706961,307.3777]);
		append(data,[-4.40575021,54.29491429,332.2987]);
		append(data,[-4.40669574,54.29438529,339.1565]);
		append(data,[-4.40863499,54.29407146,345.2232]);
		append(data,[-4.40980895,54.29366116,348.4875]);
		append(data,[-4.41182942,54.29198909,355.2360]);
		append(data,[-4.41311571,54.29129030,357.3312]);
		append(data,[-4.42537113,54.28493070,377.8236]);
		append(data,[-4.42898396,54.28240926,384.3519]);
		append(data,[-4.43510488,54.27959355,398.5180]);
		append(data,[-4.43752844,54.27896415,400.6560]);
		append(data,[-4.44127299,54.27874942,404.4296]);
		append(data,[-4.44254771,54.27851457,405.6451]);
		append(data,[-4.44349333,54.27797965,406.6105]);
		append(data,[-4.44429054,54.27691210,409.1827]);
		append(data,[-4.44506664,54.27274581,419.6910]);
		append(data,[-4.44626348,54.27008869,421.0375]);
		append(data,[-4.44877480,54.26776171,421.5112]);
		append(data,[-4.44911679,54.26707546,422.2057]);
		append(data,[-4.44906941,54.26596200,423.3301]);
		append(data,[-4.44867544,54.26498293,422.2876]);
		append(data,[-4.44858957,54.26348787,420.5955]);
		append(data,[-4.44883843,54.26285677,420.2180]);
		append(data,[-4.44999870,54.26180520,420.2473]);
		append(data,[-4.45701091,54.25821643,418.6091]);
		append(data,[-4.45805868,54.25768264,418.5433]);
		append(data,[-4.45858454,54.25696823,418.5478]);
		append(data,[-4.45921782,54.25457210,416.0305]);
		append(data,[-4.46145993,54.25256208,415.1682]);
		append(data,[-4.46251539,54.25213724,415.1901]);
		append(data,[-4.46310109,54.25158166,411.2760]);
		append(data,[-4.46314881,54.25068740,410.7636]);
		append(data,[-4.46375642,54.24978877,414.4752]);
		append(data,[-4.46654478,54.24593482,425.4013]);
		append(data,[-4.46819324,54.24457325,426.8737]);
		append(data,[-4.47008591,54.24336398,425.9326]);
		append(data,[-4.47167543,54.24279084,424.5732]);
		append(data,[-4.47232190,54.24233628,422.7039]);
		append(data,[-4.47283125,54.23951961,412.3231]);
		append(data,[-4.47305295,54.23828241,407.7762]);
		append(data,[-4.47431361,54.23591614,396.7153]);
		append(data,[-4.47423555,54.23500916,394.2719]);
		append(data,[-4.47026597,54.23125753,373.9691]);
		append(data,[-4.47004639,54.23079315,372.6738]);
		append(data,[-4.47063015,54.22981870,370.8116]);
		append(data,[-4.47265147,54.22698473,360.3470]);
		append(data,[-4.47412477,54.22392218,354.2973]);
		append(data,[-4.47569722,54.22206710,346.6044]);
		append(data,[-4.47832602,54.22046331,338.7717]);
		append(data,[-4.47902371,54.21912291,334.9355]);
		append(data,[-4.47862725,54.21760435,332.1285]);
		append(data,[-4.47895623,54.21481101,323.0089]);
		append(data,[-4.47941487,54.21427000,322.2067]);
		append(data,[-4.47942489,54.21358132,321.7076]);
		append(data,[-4.47880671,54.21272565,317.0538]);
		append(data,[-4.47687626,54.21125307,295.7909]);
		append(data,[-4.47616146,54.21092467,290.2993]);
		append(data,[-4.46689283,54.20758637,240.9739]);
		append(data,[-4.46652672,54.20692579,235.3277]);
		append(data,[-4.47271308,54.19999509,194.2886]);
		append(data,[-4.47742196,54.19595197,162.4016]);
		append(data,[-4.47774629,54.19555755,159.9539]);
		append(data,[-4.47756537,54.19493401,154.8957]);
		append(data,[-4.47434892,54.18801777,117.4211]);
		append(data,[-4.47456758,54.18725528,120.0628]);
		append(data,[-4.47517788,54.18583508,124.6784]);
		append(data,[-4.47549509,54.18356357,131.1836]);
		append(data,[-4.47528457,54.18288610,134.4144]);
		append(data,[-4.47394407,54.18141655,138.1019]);
		append(data,[-4.47056821,54.17991711,134.4230]);
		append(data,[-4.47026677,54.17954633,130.7802]);
		append(data,[-4.47151307,54.17791405,117.2937]);
		append(data,[-4.47117510,54.17695466,111.5292]);
		append(data,[-4.46859653,54.17427117,99.3442]);
		append(data,[-4.46851284,54.17299364,94.0435]);
		append(data,[-4.46792689,54.17181142,88.5796]);
		append(data,[-4.46862526,54.17181903,89.8851]);
		append(data,[-4.46915858,54.17166764,90.5378]);
		append(data,[-4.46976801,54.17116418,89.7821]);

		track.setData(data);
	}
	###############################
		elsif(nearestAirport == "EGNS" and ownLat < 54.135){
		
			track = RaceTrack.new("Isle of Man - Southern 100",54.08805533,-4.66227569);

			track.setRange(1.5);
			
			track.appendSector(RaceTrackSector.new("Start/Finish",54.07963669,-4.66226026,9,-45,10));
			track.appendSector(RaceTrackSector.new("Ballakeighan",54.08317868,-4.67434716,9,-40,10));
			track.appendSector(RaceTrackSector.new("Ballanorris",54.09320969,-4.67484413,17,-45,0));
			track.appendSector(RaceTrackSector.new("Ballabeg Hairpin",54.09700774,-4.67595356,23,0,-5));
			track.appendSector(RaceTrackSector.new("Williams",54.09494377,-4.66541349,26,25,-5));
			track.appendSector(RaceTrackSector.new("Billown Dip",54.09426643,-4.65590814,25,-8,11));
			track.appendSector(RaceTrackSector.new("Cross Four-Ways",54.09492212,-4.64682491,27,30,-8));
			track.appendSector(RaceTrackSector.new("Church Bends",54.09122619,-4.64920781,25,-6,10));
			track.appendSector(RaceTrackSector.new("Great Meadow",54.08315550,-4.65416402,15,6,0));
			track.appendSector(RaceTrackSector.new("Castletown Corner",54.07841286,-4.65588687,12,40,12));

			data = [];
		
			append(data,[-4.65589287,54.07839027,12]); # start
			append(data,[-4.65946834,54.07901912,12]);
			append(data,[-4.66468530,54.08024229,9]);
			append(data,[-4.66907569,54.08173902,10]);
			append(data,[-4.67076608,54.08222297,12]);
			append(data,[-4.67179018,54.08268575,16]);
			append(data,[-4.67444789,54.08317649,17]);
			append(data,[-4.67616554,54.09092799,15]);
			append(data,[-4.67477643,54.09329667,21]);
			append(data,[-4.67502320,54.09387234,21]);
			append(data,[-4.67488026,54.09441961,21]);
			append(data,[-4.67571246,54.09599946,24]);
			append(data,[-4.67567570,54.09672023,29]);
			append(data,[-4.67605206,54.09703220,26]);
			append(data,[-4.67252423,54.09688676,27]);
			append(data,[-4.66971026,54.09681205,25]);
			append(data,[-4.66845251,54.09624180,27]);
			append(data,[-4.66707377,54.09550104,25]);
			append(data,[-4.66402921,54.09469248,26]);
			append(data,[-4.66029839,54.09460025,25]);
			append(data,[-4.65656175,54.09422020,25]);
			append(data,[-4.65369320,54.09431248,28]);
			append(data,[-4.64864933,54.09468731,25]);
			append(data,[-4.64674777,54.09494238,27]);
			append(data,[-4.64870079,54.09153538,26]);
			append(data,[-4.64957992,54.09097703,23]);
			append(data,[-4.65184955,54.08618371,19]);
			append(data,[-4.65614260,54.08058154,12]);

			track.setData(data);
		}
###############################
	elsif((nearestAirport == "LKMT") or (nearestAirport == "LKFR")){
		
		track = RaceTrack.new("Czech - Terlicko",49.76215483,18.48063291);
		track.setRange(1.8);
		
		track.appendSector(RaceTrackSector.new("Start/Cil",49.76001107,18.48831535,290,40,0));
		track.appendSector(RaceTrackSector.new("Pekarna Sliwka",49.75357136,18.48916417,288,0,12));
		track.appendSector(RaceTrackSector.new("Stadion",49.75736570,18.47683162,292,-25,15));
		track.appendSector(RaceTrackSector.new("Rondel",49.76206989,18.46521434,337,-30,5));
		track.appendSector(RaceTrackSector.new("Zivotice",49.76509910,18.47029360,339,-35,-5));
		track.appendSector(RaceTrackSector.new("U Krizku",49.77147037,18.47734684,317,-20,-10));
		track.appendSector(RaceTrackSector.new("Sady",49.77331244,18.48528166,315,20,0));
		track.appendSector(RaceTrackSector.new("U pily",49.76317747,18.48792118,283,27,-5));
		
		data = [];
		append(data,[18.48923493,49.75383402,288]);
		append(data,[18.48902161,49.75356091,289]);
		append(data,[18.48818382,49.75392083,292]);
		append(data,[18.48334948,49.75480635,299]);
		append(data,[18.47777289,49.75685047,291]);
		append(data,[18.47741028,49.75735353,292]);
		append(data,[18.47679114,49.75727904,292]);
		append(data,[18.47673767,49.75763017,292]);
		append(data,[18.47556701,49.75769812,292]);
		append(data,[18.46579013,49.76194365,337]);
		append(data,[18.46525003,49.76201073,337]);
		append(data,[18.46512002,49.76209269,337]);
		append(data,[18.46512457,49.76223425,337]);
		append(data,[18.46536689,49.76228193,337]);
		append(data,[18.46564947,49.76230490,337]);
		append(data,[18.46757985,49.76338481,340]);
		append(data,[18.46961037,49.76486401,340]);
		append(data,[18.46999243,49.76491813,339]);
		append(data,[18.47065433,49.76527671,339]);
		append(data,[18.47071233,49.76550727,339]);
		append(data,[18.47198178,49.76607525,334]);
		append(data,[18.47243945,49.76641209,331]);
		append(data,[18.47319199,49.76734399,326]);
		append(data,[18.47601336,49.76992050,318]);
		append(data,[18.47658342,49.77059822,318]);
		append(data,[18.47701732,49.77127107,317]);
		append(data,[18.47766172,49.77160950,317]);
		append(data,[18.47872618,49.77196465,319]);
		append(data,[18.48194133,49.77253383,320]);
		append(data,[18.48416413,49.77313496,316]);
		append(data,[18.48524970,49.77326614,315]);
		append(data,[18.48547324,49.77296612,313]);
		append(data,[18.48693617,49.76873196,293]);
		append(data,[18.48774086,49.76364179,284]);
		append(data,[18.48790454,49.76336199,284]);
		append(data,[18.48797790,49.76291497,283]);
		append(data,[18.48792678,49.76247605,283]);

		track.setData(data);
	}
###############################
	elsif(nearestAirport == "EDPA"){
		
		track = RaceTrack.new("Germany - Bopfingen",48.85114679,10.33251126);
		track.setRange(0.1);
		
		track.appendSector(RaceTrackSector.new("Start/Ziel",48.85156725,10.33250669,611,40,-10));
		track.appendSector(RaceTrackSector.new("Steil-",48.85064665,10.33082405,611,-4,-8));
		track.appendSector(RaceTrackSector.new("kurve",48.85050183,10.33075016,611,20,0));
		track.appendSector(RaceTrackSector.new("Clubhaus",48.85094387,10.33418082,611,-20,10));
		
		data = [];

		append(data,[10.33376005,48.85141263,612]);
		append(data,[10.33372015,48.85132065,612]);
		append(data,[10.33332730,48.85130911,612]);
		append(data,[10.33310362,48.85117370,612]);
		append(data,[10.33288717,48.85118525,612]);
		append(data,[10.33231208,48.85143688,612]);
		append(data,[10.33211611,48.85142604,612]);
		append(data,[10.33201972,48.85130084,612]);
		append(data,[10.33198273,48.85113670,612]);
		append(data,[10.33161613,48.85102679,612]);
		append(data,[10.33160524,48.85087533,612]);
		append(data,[10.33191994,48.85086678,612]);
		append(data,[10.33226407,48.85097928,612]);
		append(data,[10.33280973,48.85100812,612]);
		append(data,[10.33297479,48.85090057,612]);
		append(data,[10.33285806,48.85079435,612]);
		append(data,[10.33233010,48.85080181,612]);
		append(data,[10.33108765,48.85044955,612]);
		append(data,[10.33079088,48.85046080,612]);
		append(data,[10.33072187,48.85057929,612]);
		append(data,[10.33103476,48.85068155,612]);
		append(data,[10.33132477,48.85076311,612]);
		append(data,[10.33134470,48.85103220,612]);
		append(data,[10.33171454,48.85121040,612]);
		append(data,[10.33183452,48.85130181,612]);
		append(data,[10.33184477,48.85143824,612]);
		append(data,[10.33147646,48.85152578,612]);
		append(data,[10.33112762,48.85148323,612]);
		append(data,[10.33104322,48.85126252,612]);
		append(data,[10.33112116,48.85089396,612]);
		append(data,[10.33097299,48.85081776,612]);
		append(data,[10.33079543,48.85090628,612]);
		append(data,[10.33078643,48.85128690,612]);
		append(data,[10.33091869,48.85154993,612]);
		append(data,[10.33115558,48.85163430,612]);
		append(data,[10.33373981,48.85154127,612]);

		track.setData(data);
	}
###############################
	elsif(nearestAirport == "OTBK"){
		
		track = RaceTrack.new("Qatar - Losail Circuit",25.48972282,51.45220188);
		track.setRange(0.9);
		
		track.appendSector(RaceTrackSector.new("Start/Ziel",25.48879949,51.44983159,13,-40,10));
		track.appendSector(RaceTrackSector.new("1",25.49319662,51.44773118,13,-6,-3));
		track.appendSector(RaceTrackSector.new("2",25.49243121,51.45045756,13,2,13));
		track.appendSector(RaceTrackSector.new("3",25.49440854,51.45077765,13,8,8));
		track.appendSector(RaceTrackSector.new("4",25.49713892,51.45351841,13,0,15));
		track.appendSector(RaceTrackSector.new("5",25.49602742,51.45476145,13,8,5));
		track.appendSector(RaceTrackSector.new("6",25.49395187,51.45314463,13,0,15));
		track.appendSector(RaceTrackSector.new("7",25.49457983,51.45688784,13,7,0));
		track.appendSector(RaceTrackSector.new("8",25.49336423,51.45623340,13,10,5));
		track.appendSector(RaceTrackSector.new("9",25.49191121,51.45560090,13,8,10));
		track.appendSector(RaceTrackSector.new("10",25.49121032,51.45361896,13,-10,-2));
		track.appendSector(RaceTrackSector.new("11",25.48968884,51.45603571,13,0,13));
		track.appendSector(RaceTrackSector.new("12",25.48988650,51.45890798,13,10,-5));
		track.appendSector(RaceTrackSector.new("13",25.48841860,51.46003737,13,12,4));
		track.appendSector(RaceTrackSector.new("14",25.48681120,51.45897448,13,4,15));
		track.appendSector(RaceTrackSector.new("15",25.48714949,51.45573293,13,7,15));
		track.appendSector(RaceTrackSector.new("16",25.48368375,51.45335060,13,4,15));
		
		data = [];

		append(data,[51.45287703,25.48383484,13]);
		append(data,[51.44758841,25.49247601,13]);
		append(data,[51.44756770,25.49292316,13]);
		append(data,[51.44783911,25.49323668,13]);
		append(data,[51.44833211,25.49328719,13]);
		append(data,[51.44991101,25.49241155,13]);
		append(data,[51.45037768,25.49239238,13]);
		append(data,[51.45067878,25.49261807,13]);
		append(data,[51.45076925,25.49292254,13]);
		append(data,[51.45074617,25.49418220,13]);
		append(data,[51.45083808,25.49451734,13]);
		append(data,[51.45105878,25.49478434,13]);
		append(data,[51.45318391,25.49699780,13]);
		append(data,[51.45344339,25.49711582,13]);
		append(data,[51.45375133,25.49708154,13]);
		append(data,[51.45462372,25.49636584,13]);
		append(data,[51.45472817,25.49595768,13]);
		append(data,[51.45458956,25.49569039,13]);
		append(data,[51.45319691,25.49426959,13]);
		append(data,[51.45312200,25.49394858,13]);
		append(data,[51.45325158,25.49381683,13]);
		append(data,[51.45357617,25.49384531,13]);
		append(data,[51.45618615,25.49479635,13]);
		append(data,[51.45663850,25.49479247,13]);
		append(data,[51.45683044,25.49467768,13]);
		append(data,[51.45698565,25.49436014,13]);
		append(data,[51.45694629,25.49403055,13]);
		append(data,[51.45659268,25.49368480,13]);
		append(data,[51.45618478,25.49327162,13]);
		append(data,[51.45591914,25.49276255,13]);
		append(data,[51.45574892,25.49217803,13]);
		append(data,[51.45556507,25.49188463,13]);
		append(data,[51.45527534,25.49174315,13]);
		append(data,[51.45390135,25.49142744,13]);
		append(data,[51.45358211,25.49118903,13]);
		append(data,[51.45358464,25.49092999,13]);
		append(data,[51.45402049,25.49044097,13]);
		append(data,[51.45471421,25.49001013,13]);
		append(data,[51.45534280,25.48977487,13]);
		append(data,[51.45595303,25.48967326,13]);
		append(data,[51.45661848,25.48967946,13]);
		append(data,[51.45864552,25.48990686,13]);
		append(data,[51.45903550,25.48986160,13]);
		append(data,[51.45935289,25.48960464,13]);
		append(data,[51.45995040,25.48866831,13]);
		append(data,[51.46005097,25.48850003,13]);
		append(data,[51.45991649,25.48812177,13]);
		append(data,[51.45912852,25.48697543,13]);
		append(data,[51.45888918,25.48678908,13]);
		append(data,[51.45860610,25.48674746,13]);
		append(data,[51.45622601,25.48720226,13]);
		append(data,[51.45584015,25.48719018,13]);
		append(data,[51.45549555,25.48692361,13]);
		append(data,[51.45380058,25.48396860,13]);
		append(data,[51.45349386,25.48371068,13]);
		append(data,[51.45321721,25.48366872,13]);
		append(data,[51.45287250,25.48383842,13]);

		track.setData(data);
	}
###############################
	elsif(nearestAirport == "SANR"){
		
		track = RaceTrack.new("Argentina - Termas de Rio Hondo",-27.50758667,-64.91501067);
		track.setRange(0.9);
		
		track.appendSector(RaceTrackSector.new("Start/Ziel",-27.51129501,-64.91888896,288,-40,15));
		track.appendSector(RaceTrackSector.new("T1",-27.50959257,-64.92197539,288,-11,-3));
		track.appendSector(RaceTrackSector.new("T2",-27.51005750,-64.91788684,288,7,13));
		track.appendSector(RaceTrackSector.new("T3",-27.50850927,-64.91849523,288,-13,-3));
		track.appendSector(RaceTrackSector.new("T4",-27.50685054,-64.91746422,288,-5,-10));
		track.appendSector(RaceTrackSector.new("T5",-27.50223168,-64.90911444,288,15,2));
		track.appendSector(RaceTrackSector.new("T6",-27.50496087,-64.91084527,288,15,5));
		track.appendSector(RaceTrackSector.new("T7",-27.50882455,-64.90917511,288,12,5));
		track.appendSector(RaceTrackSector.new("T8",-27.50929931,-64.91035235,288,-10,13));
		track.appendSector(RaceTrackSector.new("T9",-27.50689610,-64.91260435,288,2,-7));
		track.appendSector(RaceTrackSector.new("T10",-27.50731193,-64.91393966,288,-5,-7));
		track.appendSector(RaceTrackSector.new("T11",-27.50826638,-64.91643846,288,16,8));
		track.appendSector(RaceTrackSector.new("T12",-27.51165821,-64.91517557,288,15,7));
		track.appendSector(RaceTrackSector.new("T13",-27.51329451,-64.91547132,288,18,5));
		track.appendSector(RaceTrackSector.new("T14",-27.51226273,-64.91621294,288,-14,13));
		
		data = [];

		append(data,[-64.91617955,-27.51228630,288]);
		append(data,[-64.91888896,-27.51129501,288]);
		append(data,[-64.92147454,-27.51039099,288]);
		append(data,[-64.92187486,-27.51007873,288]);
		append(data,[-64.92197539,-27.50959257,288]);
		append(data,[-64.92179094,-27.50925631,288]);
		append(data,[-64.92117483,-27.50909798,288]);
		append(data,[-64.92041406,-27.50927258,288]);
		append(data,[-64.91865666,-27.51018082,288]);
		append(data,[-64.91816933,-27.51027250,288]);
		append(data,[-64.91790920,-27.51008798,288]);
		append(data,[-64.91783728,-27.50971620,288]);
		append(data,[-64.91792387,-27.50946828,288]);
		append(data,[-64.91847860,-27.50859666,288]);
		append(data,[-64.91850465,-27.50839063,288]);
		append(data,[-64.91815819,-27.50768877,288]);
		append(data,[-64.91772881,-27.50712027,288]);
		append(data,[-64.91701400,-27.50647948,288]);
		append(data,[-64.90976583,-27.50217692,288]);
		append(data,[-64.90941416,-27.50210648,288]);
		append(data,[-64.90922540,-27.50218569,288]);
		append(data,[-64.90907588,-27.50233965,288]);
		append(data,[-64.90904628,-27.50259425,288]);
		append(data,[-64.90922700,-27.50291266,288]);
		append(data,[-64.91033297,-27.50386487,288]);
		append(data,[-64.91073790,-27.50455681,288]);
		append(data,[-64.91091530,-27.50538433,288]);
		append(data,[-64.91076510,-27.50624226,288]);
		append(data,[-64.90919323,-27.50878825,288]);
		append(data,[-64.90925882,-27.50901732,288]);
		append(data,[-64.90952047,-27.50921885,288]);
		append(data,[-64.90992792,-27.50933929,288]);
		append(data,[-64.91032684,-27.50931821,288]);
		append(data,[-64.91103373,-27.50898390,288]);
		append(data,[-64.91249012,-27.50697743,288]);
		append(data,[-64.91275514,-27.50684375,288]);
		append(data,[-64.91302239,-27.50689808,288]);
		append(data,[-64.91392525,-27.50732155,288]);
		append(data,[-64.91431016,-27.50735068,288]);
		append(data,[-64.91516158,-27.50736480,288]);
		append(data,[-64.91584593,-27.50763486,288]);
		append(data,[-64.91635466,-27.50814904,288]);
		append(data,[-64.91652097,-27.50886704,288]);
		append(data,[-64.91635849,-27.50950372,288]);
		append(data,[-64.91523932,-27.51157112,288]);
		append(data,[-64.91510344,-27.51221990,288]);
		append(data,[-64.91512859,-27.51287062,288]);
		append(data,[-64.91528213,-27.51318873,288]);
		append(data,[-64.91550629,-27.51328634,288]);
		append(data,[-64.91581120,-27.51316807,288]);
		append(data,[-64.91600413,-27.51289430,288]);

		track.setData(data);
	}
###############################
	elsif(nearestAirport == "02XS"){
		
		track = RaceTrack.new("Austin, Texas - Circuit of the Americas",30.13540734,-97.63377384);
		track.setRange(0.9);
		
		track.appendSector(RaceTrackSector.new("Start/Finish",30.13207087,-97.64015017,165,-35,15));
		track.appendSector(RaceTrackSector.new("T1",30.13006670,-97.63683541,165,-10,13));
		track.appendSector(RaceTrackSector.new("T2",30.13216331,-97.63729393,165,12,6));
		track.appendSector(RaceTrackSector.new("T3",30.13375554,-97.63503285,165,7,13));
		track.appendSector(RaceTrackSector.new("T4",30.13450102,-97.63438727,165,10,12));
		track.appendSector(RaceTrackSector.new("T5",30.13511277,-97.63373078,165,12,7));
		track.appendSector(RaceTrackSector.new("T6",30.13616262,-97.63285486,165,-5,-5));
		track.appendSector(RaceTrackSector.new("T7",30.13573370,-97.63122123,165,3,15));
		track.appendSector(RaceTrackSector.new("T8",30.13664212,-97.62982420,165,0,15));
		track.appendSector(RaceTrackSector.new("T9",30.13619984,-97.62910291,165,5,-8));
		track.appendSector(RaceTrackSector.new("T10",30.13654145,-97.62706103,165,5,13));
		track.appendSector(RaceTrackSector.new("T11",30.13940725,-97.62453005,165,17,5));
		track.appendSector(RaceTrackSector.new("T12",30.13727476,-97.63658713,165,5,-10));
		track.appendSector(RaceTrackSector.new("T13",30.13561531,-97.63546765,165,5,-5));
		track.appendSector(RaceTrackSector.new("T14",30.13565812,-97.63650963,165,14,8));
		track.appendSector(RaceTrackSector.new("T15",30.13655182,-97.63773828,165,-12,-5));
		track.appendSector(RaceTrackSector.new("T16",30.13473036,-97.63679913,165,5,5));
		track.appendSector(RaceTrackSector.new("T17",30.13398351,-97.63711150,165,-14,-3));
		track.appendSector(RaceTrackSector.new("T18",30.13367564,-97.63872845,165,-18,5));
		track.appendSector(RaceTrackSector.new("T19",30.13547071,-97.64065212,165,5,-7));
		track.appendSector(RaceTrackSector.new("T20",30.13436214,-97.64351998,165,-18,5));

		
		data = [];

		append(data,[-97.64357076,30.13440662,148]);
		append(data,[-97.63685916,30.13002877,148]);
		append(data,[-97.63734072,30.13160228,148]);
		append(data,[-97.63733462,30.13204601,148]);
		append(data,[-97.63706365,30.13248224,148]);
		append(data,[-97.63541952,30.13334908,148]);
		append(data,[-97.63513477,30.13358216,148]);
		append(data,[-97.63490135,30.13404909,148]);
		append(data,[-97.63466352,30.13435839,148]);
		append(data,[-97.63425979,30.13453853,148]);
		append(data,[-97.63387255,30.13477336,148]);
		append(data,[-97.63372738,30.13525900,148]);
		append(data,[-97.63355647,30.13570777,148]);
		append(data,[-97.63312703,30.13603613,148]);
		append(data,[-97.63246269,30.13618555,148]);
		append(data,[-97.63123982,30.13572664,148]);
		append(data,[-97.63008122,30.13655635,148]);
		append(data,[-97.62964157,30.13664103,148]);
		append(data,[-97.62923030,30.13634803,148]);
		append(data,[-97.62903937,30.13615602,148]);
		append(data,[-97.62706199,30.13654463,148]);
		append(data,[-97.62454311,30.13940430,148]);
		append(data,[-97.62864957,30.13845605,148]);
		append(data,[-97.63126170,30.13797331,148]);
		append(data,[-97.63652875,30.13735451,148]);
		append(data,[-97.63665308,30.13721904,148]);
		append(data,[-97.63547837,30.13575578,148]);
		append(data,[-97.63560382,30.13549402,148]);
		append(data,[-97.63624365,30.13550823,148]);
		append(data,[-97.63656158,30.13573309,148]);
		append(data,[-97.63668721,30.13612334,148]);
		append(data,[-97.63712031,30.13650818,148]);
		append(data,[-97.63783634,30.13652231,148]);
		append(data,[-97.63687143,30.13499538,148]);
		append(data,[-97.63679973,30.13475328,148]);
		append(data,[-97.63705959,30.13404774,148]);
		append(data,[-97.63732787,30.13388306,148]);
		append(data,[-97.63799684,30.13362001,148]);
		append(data,[-97.63841549,30.13360449,148]);
		append(data,[-97.63890315,30.13372939,148]);
		append(data,[-97.63944097,30.13413493,148]);
		append(data,[-97.64051706,30.13538787,148]);
		append(data,[-97.64074920,30.13548431,148]);
		append(data,[-97.64333088,30.13460499,148]);

		track.setData(data);
	}
###############################
	elsif(nearestAirport == "LEJR"){
		
		track = RaceTrack.new("Espagna - Circuito de Jerez",36.70815352,-6.031699731);
		track.setRange(0.7);
		
		track.appendSector(RaceTrackSector.new("Start",36.70985854,-6.03260098,45,-18,-5));
		track.appendSector(RaceTrackSector.new("Expo 92",36.71269249,-6.03384453,45,-30,5));
		track.appendSector(RaceTrackSector.new("Michelin",36.71269425,-6.03122354,45,35,5));
		track.appendSector(RaceTrackSector.new("T3",36.71183506,-6.03202660,45,12,8));
		track.appendSector(RaceTrackSector.new("T4",36.70990774,-6.03183570,45,10,-2));
		track.appendSector(RaceTrackSector.new("Sito Pons",36.70838780,-6.02715123,45,38,2));
		track.appendSector(RaceTrackSector.new("Dry Sac",36.70411156,-6.03329890,45,0,14));
		track.appendSector(RaceTrackSector.new("Martinez",36.70632114,-6.03243023,45,34,9));
		track.appendSector(RaceTrackSector.new("Aspar",36.70832061,-6.03488595,45,7,26));
		track.appendSector(RaceTrackSector.new("Nieto",36.70602184,-6.03662233,45,6,13));
		track.appendSector(RaceTrackSector.new("Peluqui",36.70662647,-6.03795038,45,-31,3));
		track.appendSector(RaceTrackSector.new("Criville",36.70914001,-6.03632673,45,-40,5));
		track.appendSector(RaceTrackSector.new("Ferrari",36.70909264,-6.03410278,45,-25,-9));
		track.appendSector(RaceTrackSector.new("Lorenzo",36.70694690,-6.03145037,45,32,2));

		
		data = [];

		append(data,[-6.03126796,36.70723282,42]);
		append(data,[-6.03393129,36.71245217,42]);
		append(data,[-6.03385862,36.71268920,42]);
		append(data,[-6.03366023,36.71280279,42]);
		append(data,[-6.03147632,36.71283716,42]);
		append(data,[-6.03126001,36.71272181,42]);
		append(data,[-6.03129460,36.71237079,42]);
		append(data,[-6.03179950,36.71204241,42]);
		append(data,[-6.03204936,36.71176638,42]);
		append(data,[-6.03214073,36.71141217,42]);
		append(data,[-6.03204605,36.71037008,42]);
		append(data,[-6.03192006,36.71002151,42]);
		append(data,[-6.03162926,36.70969000,42]);
		append(data,[-6.03114583,36.70948150,42]);
		append(data,[-6.02782579,36.70909035,42]);
		append(data,[-6.02752036,36.70894325,42]);
		append(data,[-6.02722770,36.70863885,42]);
		append(data,[-6.02710719,36.70825453,42]);
		append(data,[-6.02734070,36.70771449,42]);
		append(data,[-6.03284130,36.70411393,42]);
		append(data,[-6.03309255,36.70402216,42]);
		append(data,[-6.03332372,36.70407417,42]);
		append(data,[-6.03346387,36.70432066,42]);
		append(data,[-6.03344294,36.70441413,42]);
		append(data,[-6.03249004,36.70595536,42]);
		append(data,[-6.03241059,36.70624893,42]);
		append(data,[-6.03252707,36.70668788,42]);
		append(data,[-6.03392935,36.70817920,42]);
		append(data,[-6.03458583,36.70839277,42]);
		append(data,[-6.03510299,36.70827212,42]);
		append(data,[-6.03570027,36.70778118,42]);
		append(data,[-6.03635163,36.70624351,42]);
		append(data,[-6.03653939,36.70603627,42]);
		append(data,[-6.03688341,36.70596276,42]);
		append(data,[-6.03716042,36.70606968,42]);
		append(data,[-6.03780272,36.70646592,42]);
		append(data,[-6.03797887,36.70664495,42]);
		append(data,[-6.03795143,36.70688841,42]);
		append(data,[-6.03673392,36.70880755,42]);
		append(data,[-6.03650823,36.70905383,42]);
		append(data,[-6.03604163,36.70925626,42]);
		append(data,[-6.03560290,36.70927036,42]);
		append(data,[-6.03427277,36.70918028,42]);
		append(data,[-6.03394198,36.70901477,42]);
		append(data,[-6.03187193,36.70696796,42]);
		append(data,[-6.03165504,36.70689132,42]);
		append(data,[-6.03131197,36.70702536,42]);

		track.setData(data);
	}
###############################
	elsif((nearestAirport == "LKCM")){
		
		track = RaceTrack.new("Czech - Automotodrom Brno",49.20534932,16.45284913);
		track.setRange(0.8);
		
		track.appendSector(RaceTrackSector.new("Start/Cil",49.20279939,16.44534981,450,-40,10));
		track.appendSector(RaceTrackSector.new("T1",49.20540592,16.43919046,288,-14,5));
		track.appendSector(RaceTrackSector.new("T2",49.20577427,16.44234620,292,0,-13));
		track.appendSector(RaceTrackSector.new("T3",49.20624123,16.45073562,337,-15,-4));
		track.appendSector(RaceTrackSector.new("T4",49.20793728,16.45012332,339,-10,-10));
		track.appendSector(RaceTrackSector.new("T5",49.20909908,16.45781564,317,12,0));
		track.appendSector(RaceTrackSector.new("T6",49.20748514,16.45747499,317,16,0));
		track.appendSector(RaceTrackSector.new("T7",49.20710825,16.45524075,317,-10,-4));
		track.appendSector(RaceTrackSector.new("T8",49.20559780,16.45846799,317,4,15));
		track.appendSector(RaceTrackSector.new("T9",49.20663674,16.45966917,317,18,0));
		track.appendSector(RaceTrackSector.new("T10",49.20185404,16.46425459,317,20,10));
		track.appendSector(RaceTrackSector.new("T11",49.20279808,16.45968302,317,0,-9));
		track.appendSector(RaceTrackSector.new("T12",49.20182068,16.45861682,317,0,15));
		track.appendSector(RaceTrackSector.new("T13",49.20332101,16.45054183,317,0,-9));
		track.appendSector(RaceTrackSector.new("T14",49.20196509,16.44942609,317,0,15));
		
		data = [];
		append(data,[16.45006530,49.20243558,452]);
		append(data,[16.44956135,49.20202376,453]);
		append(data,[16.44891336,49.20192196,453]);
		append(data,[16.44812407,49.20201292,453]);
		append(data,[16.43978924,49.20444142,450]);
		append(data,[16.43938430,49.20469167,450]);
		append(data,[16.43914151,49.20531257,449]);
		append(data,[16.43958893,49.20591902,448]);
		append(data,[16.44005588,49.20611584,449]);
		append(data,[16.44122660,49.20605795,450]);
		append(data,[16.44220457,49.20581047,451]);
		append(data,[16.44284743,49.20577306,451]);
		append(data,[16.45006614,49.20596481,463]);
		append(data,[16.45061091,49.20611641,463]);
		append(data,[16.45085453,49.20647598,463]);
		append(data,[16.45026334,49.20746011,462]);
		append(data,[16.45013092,49.20790192,462]);
		append(data,[16.45036114,49.20822863,462]);
		append(data,[16.45088028,49.20836006,461]);
		append(data,[16.45717725,49.20925227,440]);
		append(data,[16.45759012,49.20917539,440]);
		append(data,[16.45793950,49.20890293,439]);
		append(data,[16.45798477,49.20860949,439]);
		append(data,[16.45781602,49.20789859,436]);
		append(data,[16.45760136,49.20756400,435]);
		append(data,[16.45718687,49.20741907,434]);
		append(data,[16.45587877,49.20742301,432]);
		append(data,[16.45539402,49.20725616,432]);
		append(data,[16.45519605,49.20702175,431]);
		append(data,[16.45519737,49.20671238,431]);
		append(data,[16.45558604,49.20639911,430]);
		append(data,[16.45779196,49.20560950,425]);
		append(data,[16.45825022,49.20553141,424]);
		append(data,[16.45864200,49.20565160,424]);
		append(data,[16.45883761,49.20592000,424]);
		append(data,[16.45905683,49.20639870,423]);
		append(data,[16.45947906,49.20661170,423]);
		append(data,[16.46009162,49.20659118,422]);
		append(data,[16.46053882,49.20633648,420]);
		append(data,[16.46430749,49.20257549,395]);
		append(data,[16.46448229,49.20218707,394]);
		append(data,[16.46423433,49.20177666,394]);
		append(data,[16.46374277,49.20161879,394]);
		append(data,[16.46319002,49.20163037,395]);
		append(data,[16.46027797,49.20274450,398]);
		append(data,[16.45971657,49.20283446,399]);
		append(data,[16.45934811,49.20266383,400]);
		append(data,[16.45901514,49.20206945,404]);
		append(data,[16.45873859,49.20185773,406]);
		append(data,[16.45804008,49.20184373,408]);
		append(data,[16.45134993,49.20342789,447]);
		append(data,[16.45071388,49.20342399,448]);
		append(data,[16.45036678,49.20315223,449]);

		track.setData(data);
	}
###############################
	elsif((nearestAirport == "EGBT")){
		
		track = RaceTrack.new("Great Britain - Silverstone Circuit",52.07066085,-1.01612500);
		track.setRange(0.9);
		track.setRotation(90);
		
		track.appendSector(RaceTrackSector.new("Finish",52.07859834,-1.01725098,162,-27,5));
		track.appendSector(RaceTrackSector.new("Copse",52.07845034,-1.01152091,163,-25,5));
		track.appendSector(RaceTrackSector.new("Maggots",52.07417979,-1.01039878,164,-25,-5));
		track.appendSector(RaceTrackSector.new("Becketts",52.07204444,-1.01034478,162,10,-12));
		track.appendSector(RaceTrackSector.new("Chapel",52.07003907,-1.01115281,162,28,-3));
		track.appendSector(RaceTrackSector.new("Hangar Straight",52.06754662,-1.01333563,160,60,0));
		track.appendSector(RaceTrackSector.new("Stowe",52.06338804,-1.01825811,157,25,0));
		track.appendSector(RaceTrackSector.new("Vale",52.06642351,-1.02253253,156,24,4));
		track.appendSector(RaceTrackSector.new("Club",52.06744724,-1.02463088,155,0,12));
		track.appendSector(RaceTrackSector.new("Abbey",52.07119108,-1.01973399,159,26,4));
		track.appendSector(RaceTrackSector.new("Farm",52.07111705,-1.01674847,160,20,4));
		track.appendSector(RaceTrackSector.new("Village",52.07239445,-1.01352604,164,30,8));
		track.appendSector(RaceTrackSector.new("Loop",52.07127129,-1.01260338,164,17,6));
		track.appendSector(RaceTrackSector.new("Aintree",52.07291132,-1.01172203,164,-33,5));
		track.appendSector(RaceTrackSector.new("Wellington Straight",52.07431158,-1.01415381,163,-12,12));
		track.appendSector(RaceTrackSector.new("Brooklands",52.07704940,-1.01957569,159,40,0));
		track.appendSector(RaceTrackSector.new("Luffield",52.07569750,-1.02113410,160,0,20));
		track.appendSector(RaceTrackSector.new("Woodcote",52.07757048,-1.02088639,161,-32,8));
		
		data = [];
		append(data,[-1.02453381,52.06755623,155]);
		append(data,[-1.02015666,52.07102742,159]);
		append(data,[-1.01905597,52.07120176,159]);
		append(data,[-1.01759773,52.07107877,160]);
		append(data,[-1.01669286,52.07113209,160]);
		append(data,[-1.01599408,52.07131763,160]);
		append(data,[-1.01389905,52.07235510,164]);
		append(data,[-1.01350912,52.07239995,164]);
		append(data,[-1.01323120,52.07213367,164]);
		append(data,[-1.01294076,52.07154826,164]);
		append(data,[-1.01275391,52.07132047,164]);
		append(data,[-1.01233751,52.07128163,164]);
		append(data,[-1.01188453,52.07188215,164]);
		append(data,[-1.01170145,52.07261204,164]);
		append(data,[-1.01170003,52.07288714,164]);
		append(data,[-1.01202219,52.07311351,164]);
		append(data,[-1.01889482,52.07695767,159]);
		append(data,[-1.01958678,52.07704252,159]);
		append(data,[-1.02018916,52.07686959,159]);
		append(data,[-1.02041502,52.07600179,160]);
		append(data,[-1.02085731,52.07572920,160]);
		append(data,[-1.02151609,52.07572435,160]);
		append(data,[-1.02192443,52.07599518,160]);
		append(data,[-1.02185562,52.07641832,160]);
		append(data,[-1.02091891,52.07753424,161]);
		append(data,[-1.02029000,52.07799778,161]);
		append(data,[-1.01916595,52.07843775,161]);
		append(data,[-1.01249149,52.07881020,163]);
		append(data,[-1.01181862,52.07863833,163]);
		append(data,[-1.01120767,52.07805548,164]);
		append(data,[-1.01065142,52.07659875,164]);
		append(data,[-1.01041871,52.07431813,164]);
		append(data,[-1.01017470,52.07383257,164]);
		append(data,[-1.00977019,52.07328699,164]);
		append(data,[-1.01004582,52.07263686,163]);
		append(data,[-1.01034752,52.07202949,162]);
		append(data,[-1.00999237,52.07143110,162]);
		append(data,[-1.00956368,52.07078690,162]);
		append(data,[-1.01005055,52.07027659,162]);
		append(data,[-1.01110659,52.07005923,162]);
		append(data,[-1.01663927,52.06401235,157]);
		append(data,[-1.01738606,52.06350568,157]);
		append(data,[-1.01827673,52.06337897,157]);
		append(data,[-1.01912044,52.06369617,157]);
		append(data,[-1.02020509,52.06486776,157]);
		append(data,[-1.02178898,52.06596449,157]);
		append(data,[-1.02221230,52.06630723,156]);
		append(data,[-1.02255564,52.06642612,156]);
		append(data,[-1.02292410,52.06626620,156]);
		append(data,[-1.02329497,52.06608112,156]);
		append(data,[-1.02381006,52.06625543,156]);
		append(data,[-1.02462839,52.06715538,155]);

		track.setData(data);
	}
	###############################
	elsif((nearestAirport == "LEVC")){
		
		track = RaceTrack.new("Espagna - Circuit Ricardo Tormo, Valencia",39.48522545,-0.63070886);
		track.setRange(0.4);
		track.setRotation(-35);
		
		track.appendSector(RaceTrackSector.new("Start/Finish",39.48352442,-0.63107623,163,16,17));
		track.appendSector(RaceTrackSector.new("1 Aspar",39.48624960,-0.62619237,163,0,20));
		track.appendSector(RaceTrackSector.new("Doohan",39.48937561,-0.62778749,164,9,-10));
		track.appendSector(RaceTrackSector.new("2",39.48937561,-0.62778749,164,10,0));
		track.appendSector(RaceTrackSector.new("3 ",39.48798760,-0.62826448,162,12,7));
		track.appendSector(RaceTrackSector.new("4",39.48674678,-0.62715779,164,-11,-5));
		track.appendSector(RaceTrackSector.new("N.Terol",39.48674678,-0.62715779,164,-15,14));
		track.appendSector(RaceTrackSector.new("5",39.48609148,-0.62883411,162,-10,0));
		track.appendSector(RaceTrackSector.new("6",39.48839112,-0.62927673,162,6,-4));
		track.appendSector(RaceTrackSector.new("A.Nieto ",39.48839112,-0.62927673,162,8,-15));
		track.appendSector(RaceTrackSector.new("7",39.48691625,-0.63267760,160,-13,0));
		track.appendSector(RaceTrackSector.new("Curva de la Aficion",39.48691625,-0.63267760,160,-15,-10));
		track.appendSector(RaceTrackSector.new("8 B.Martinez",39.48525131,-0.63357134,157,-48,0));
		track.appendSector(RaceTrackSector.new("9",39.48578363,-0.63164203,157,0,-7));
		track.appendSector(RaceTrackSector.new("10",39.48673664,-0.63132601,157,0,-5));
		track.appendSector(RaceTrackSector.new("11",39.48718634,-0.63002428,156,-14,4));
		track.appendSector(RaceTrackSector.new("12 C.Herreros",39.48457358,-0.63181668,155,7,12));
		track.appendSector(RaceTrackSector.new("13",39.48416688,-0.63416515,159,0,15));
		track.appendSector(RaceTrackSector.new("14 A.Campos",39.48158735,-0.63489018,159,30,20));
		
		data = [];
		append(data,[-0.63468635,39.48159873,162.8825]);
		append(data,[-0.62644286,39.48604369,150.9589]);
		append(data,[-0.62615989,39.48634419,150.4310]);
		append(data,[-0.62615791,39.48677457,150.0757]);
		append(data,[-0.62742863,39.48917626,152.4150]);
		append(data,[-0.62765348,39.48935612,152.7312]);
		append(data,[-0.62795305,39.48936330,153.1880]);
		append(data,[-0.62813557,39.48919064,153.4579]);
		append(data,[-0.62830363,39.48808916,153.7452]);
		append(data,[-0.62820034,39.48784267,153.6033]);
		append(data,[-0.62727666,39.48696376,152.1946]);
		append(data,[-0.62718988,39.48677102,152.0704]);
		append(data,[-0.62734965,39.48658891,152.3488]);
		append(data,[-0.62828765,39.48608006,155.1973]);
		append(data,[-0.62862248,39.48601301,156.3615]);
		append(data,[-0.62901062,39.48625056,157.6919]);
		append(data,[-0.62909077,39.48645297,157.9807]);
		append(data,[-0.62910525,39.48816636,159.2833]);
		append(data,[-0.62926102,39.48839970,160.0932]);
		append(data,[-0.62967264,39.48850207,161.8134]);
		append(data,[-0.63261148,39.48698090,170.0690]);
		append(data,[-0.63276627,39.48684108,170.3799]);
		append(data,[-0.63365549,39.48566529,170.1545]);
		append(data,[-0.63366342,39.48538154,170.1536]);
		append(data,[-0.63322201,39.48505492,170.1508]);
		append(data,[-0.63288405,39.48506625,170.1496]);
		append(data,[-0.63179017,39.48564024,167.9537]);
		append(data,[-0.63158111,39.48590464,167.9205]);
		append(data,[-0.63139170,39.48656672,167.2695]);
		append(data,[-0.63115273,39.48688823,166.0872]);
		append(data,[-0.63047917,39.48723994,162.8027]);
		append(data,[-0.63007064,39.48722263,160.7565]);
		append(data,[-0.62992081,39.48699808,160.0450]);
		append(data,[-0.63164634,39.48467225,163.8719]);
		append(data,[-0.63196500,39.48454378,164.8445]);
		append(data,[-0.63224285,39.48456656,165.7069]);
		append(data,[-0.63262447,39.48459221,166.8951]);
		append(data,[-0.63306405,39.48456640,168.2492]);
		append(data,[-0.63355167,39.48446027,169.1430]);
		append(data,[-0.63395119,39.48429752,169.1654]);
		append(data,[-0.63433660,39.48405583,169.0676]);
		append(data,[-0.63470719,39.48370190,167.6263]);
		append(data,[-0.63502222,39.48322326,166.0069]);
		append(data,[-0.63520557,39.48265500,164.4802]);
		append(data,[-0.63512865,39.48173561,163.1436]);
		append(data,[-0.63496183,39.48161132,163.0498]);

		track.setData(data);
	}
###############################
	else{
		track = nil;
	}
	
	if( track != nil ){
		raceMap.setRaceTrack(track);
		raceMap.open();
	}
};


var close = func(){
	raceMap.close();
};

var reload = func(){
	close();
	io.load_nasal(getprop("/sim/fg-home")~"/Nasal/road_racer_map.nas");
};


#print("RaceMap nasal code loaded.\n");
fgcommand("gui-redraw");