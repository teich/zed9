// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



$(document).ready(function () {  
	Array.max = function( array ){
	    return Math.max.apply( Math, array );
	};
	Array.min = function( array ){
	    return Math.min.apply( Math, array );
	};
	
	var heartrate;
	var elevation;
	var speed;
	var myData;
	
	var compFields = [ "heartrate", "elevation", "speed" ];
	var workoutURL = "/workouts/" + WORKOUT_ID + ".js"

	var options = {
		grid: { borderWidth: 0 }, 
		xaxis: {ticks: []}, 
		yaxis: {ticks:[]},
		colors: [ "#25a1d6", "#3dc10b", "#545454" ],
		shadowSize: 0 
	};
	

	$.getJSON(workoutURL, function(json) {
		heartrate = json.workout.json_heartrate;
		elevation = json.workout.json_elevation;
		speed = json.workout.json_speed;
		avghr = json.workout.average_hr;
		gain = json.workout.elevation_gain
		avg_speed = json.workout.avg_speed

		$.plot($('#heartrate'), [heartrate, {data: [[22, avghr]], bars: { show: true, lineWidth: 1 }}], options)
		$.plot($('#elevation'), [elevation, {data: [[22, gain]], bars: { show: true, lineWidth: 1 }}], options)
		$.plot($('#speed'), [speed, {data: [[22, avg_speed]], bars: { show: true, lineWidth: 1 }}], options)
		
		
	});
	
	
	
	// $.each(compFields, function(i) {
	// 	//var url = workoutURL + compFields[i];
	// 	//$.getJSON(url, function(data) {
	// 	//	myData = data;
	// 	//	myData.lines = { show: true };
	// 		$.plot($('#' + compFields[i]), [myData], options);
	// 	});
	// });
});