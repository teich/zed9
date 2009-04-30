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
	
	var bar_options = {
		grid: { borderWidth: 0 }, 
		xaxis: { ticks: [], min: 0 },
		yaxis: { ticks: [], min: 0},
		colors: [ "#25a1d6", "#3dc10b", "#545454" ],
		shadowSize: 0 
	};
	
	var full_size_options = {
		grid: { 
			borderWidth: 0,
			borderColor: "#d9d9d9", 
			tickColor: '#ffffff',
			autoHighlight: "yes",
	    hoverable: "yes",
	    mouseActiveRadius: 24,
	    show: 'both'
		}, 
		colors: [ "#25a1d6", "#3dc10b", "#545454" ],
		shadowSize: 0, 
	  xaxis: {
	    tickSize: 30
		},
	  yaxis: {
	    tickSize: 20 
		}
	};
		
	 $.getJSON(workoutURL, function(json) {
	 	heartrate = json.workout.json_heartrate;
	 	heartrate_big = json.workout.json_heartrate_big;
	 	elevation = json.workout.json_elevation;
	 	speed = json.workout.json_speed;
	 	avghr = json.workout.average_hr;
	 	gain = json.workout.elevation_gain
	 	avg_speed = json.workout.avg_speed
		duration = json.workout.duration
		distance = json.workout.distance
		
		// $.plot($('#duration'), [{ 
		// 	data: [[0, duration]], 
		// 	bars: { horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] } }
		// 	}], bar_options);
	 
	
	
	//  -------------------------
    var d1 = [[duration, .8]]; 
    var d2 = [[4000,.4]];
    var d3 = [[7000,0]];


	$.plot( $("#duration"), [{
				data: d1,
	            bars: { 
					horizontal: true, 
					show: true, 
					lineWidth: 1, 
					fillColor: { 
						colors: [{ opacity: 0.2 }, { opacity: 1 }] 
					} 
				}
			}, {
				data: d2,
	            bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }  }
			},
			{
				data: d3,
		        bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }  }
			}], {
	        xaxis: { ticks: [], min: 0 },
	        yaxis: { ticks: [], min: 0 },
			colors: ["#25a1d6", "#3dc10b", "#545454" ],
			grid: { borderWidth: 0 }
	});
    


	//  -------------------------

	
	 	$.plot($('#heartrate'), [{
				data: heartrate,
				lines: {
					show: true, 
					fill: true, 
					fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } 
				}
			}, {
				data: [[22, avghr]], 
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[24, avghr]], 
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
					}
				}, {
					data: [[26, avghr]], 
					bars: { 
						show: true, 
						lineWidth: 1, 
						fillColor: {colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
					}
				}], 
				options
			)

	 	$.plot($('#elevation'), [ {
			data: elevation,
			lines: {
				show: true, 
				fill: true, 
				fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } 
			}
		}, {
				data: [[22, gain]], 
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[24, gain]], 
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[26, gain]], 
				bars: { 
					show: true, 
					lineWidth: 1,
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}], 
			options)

	 	$.plot($('#speed'), [ {
				data: speed,
				lines: {
					show: true, 
					fill: true, 
					fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } 
				}
			}, {
				data: [[22, avg_speed]], 
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[24, avg_speed]], 
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[26, avg_speed]], 
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}], 
			options)
	 	
	 	$.plot($('#fullsize_chart'), [ {
				data: heartrate_big, 
				lines: {
					show: true, 
					fill: true, 
					fillColor: { colors: [{ opacity: 0 }, { opacity: 0.1 }] } 
				}
			}],
			full_size_options)
	 	
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
					x:-204,
					y:-201
				}				
			},
			style: { 
				width: 288,
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