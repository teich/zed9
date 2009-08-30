google.load("maps", "2.s");
var z9map = {};

// show the current location icon
function setCurrLoc(map, lat, lon)
{
	map.currLocMarker.setLatLng(new google.maps.LatLng(lat, lon));
	map.currLocMarker.show();
}


function z9MapInit(points) {
	z9map.points = [];
	z9map.pointsByRoundedTime = {};
	z9map.defaultLoc    = new GLatLng(0, 0);
	z9map.gmap = new google.maps.Map2(document.getElementById("map_div"));
	z9map.gmap.setCenter(z9map.defaultLoc, 1);
	z9map.gmap.addMapType(G_PHYSICAL_MAP) ; 
	z9map.bounds = new google.maps.LatLngBounds();
	   
		// Setup the points we're using
	for (var i = 0; i < points.length; i++) {
		lat = points[i]["data"][0];
		lng = points[i]["data"][1];
		time = points[i]["time"];
		z9map.points[i] = new google.maps.LatLng(lat, lng);
		z9map.bounds.extend(z9map.points[i])
		// console.log("Setting a point to " + time)
		z9map.pointsByRoundedTime[time] = z9map.points[i];
	}
	
	z9map.gmap.addOverlay(new google.maps.Polyline(z9map.points), "#a000f0", 3, 1.0);
    z9map.gmap.addControl(new google.maps.SmallZoomControl());
	z9map.gmap.addControl(new google.maps.MenuMapTypeControl());
	
	z9map.gmap.setCenter(z9map.bounds.getCenter(), z9map.gmap.getBoundsZoomLevel(z9map.bounds));
	
	// Setup current location icon
	var currLocIcon = new google.maps.Icon();
	currLocIcon.image = "/images/curr_loc.png";
	currLocIcon.shadow = "";
	currLocIcon.iconSize = new google.maps.Size(50,50);
	currLocIcon.iconAnchor = new google.maps.Point(26, 26);
	var currLocMarkerOptions = { icon:currLocIcon, clickable:false };
	z9map.currLocMarker = new google.maps.Marker(z9map.defaultLoc, currLocMarkerOptions);
	z9map.gmap.addOverlay(z9map.currLocMarker);
	z9map.currLocMarker.hide();
	
}

