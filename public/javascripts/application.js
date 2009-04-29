// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



$(document).ready(function () {  

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

	$('.stat').qtip({
			content: '<div class="stat"><p class="comp_this_workout"><span class="value">1:32</span>h for this hike</p> <p class="comp_my_activity"><span class="value">2:08</span>h average for all your hikes</p> <p class="comp_activity"><span class="value">0:55</span>h average for everyone\'s hikes</p></div>',
			show: 'mouseover',
			hide: 'mouseout',
			position: {
				type: 'absolute',
				container: $('td.number'),
				corner: {
					tooltip: 'topLeft',
					target: 'topRight'
				},
				adjust: {
					x:-202,
					y:-193
				}				
			},
			style: { 
				padding: 8,
				background: '#f0f0f0',
				color: '#545454',
				textAlign: 'left',
				border: {
				   width: 1,
				   radius: 8,
				   color: '#f0f0f0'
				},
	   	}
	});
	
});