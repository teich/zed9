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
		y2axis: {ticks:[], autoscaleMargin: .2},
		
		colors: [ "#25a1d6", "#3dc10b", "#545454" ],
		shadowSize: 1, 
	};
	
	var bar_options = {
		grid: { borderWidth: 0 }, 
		xaxis: { ticks: [], min: 0 },
		yaxis: { ticks: [], min: 0},
		colors: [ "#25a1d6", "#3dc10b", "#545454" ],
		shadowSize: 1, 
	};
	
	var full_size_options = {
		grid: { 
			borderWidth: 0,
			borderColor: "#d9d9d9", 
			tickColor: '#ffffff',
	    hoverable: "yes",
	    mouseActiveRadius: 24,
		}, 
		colors: [ "#25a1d6", "#3dc10b", "#545454" ],
		shadowSize: 1, 
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
		
		all_comps_speed = json.workout.json_comps.all_comps.speed
		all_comps_duration = json.workout.json_comps.all_comps.duration
		all_comps_distance = json.workout.json_comps.all_comps.distance
		all_comps_hr = json.workout.json_comps.all_comps.hr
		all_comps_elevation = json.workout.json_comps.all_comps.elevation
		
		
		my_comps_speed = json.workout.json_comps.my_comps.speed
		my_comps_duration = json.workout.json_comps.my_comps.duration
		my_comps_distance = json.workout.json_comps.my_comps.distance
		my_comps_hr = json.workout.json_comps.my_comps.hr
		my_comps_elevation = json.workout.json_comps.my_comps.elevation
		
				
		// $.plot($('#duration'), [{ 
		// 	data: [[0, duration]], 
		// 	bars: { horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] } }
		// 	}], bar_options);
	 
	
	
	//  -------------------------

	$.plot( $("#duration"), [{
				data: [[duration, .8]],
	            bars: { 
					horizontal: true, 
					show: true, 
					lineWidth: 1, 
					fillColor: { 
						colors: [{ opacity: 0.2 }, { opacity: 1 }] 
					} 
				}
			}, {
				data: [[my_comps_duration, .4]],
	            bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }  }
			},
			{
				data: [[all_comps_duration, 0.0]],
		        bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }  }
			}], {
	        xaxis: { ticks: [], min: 0 },
	        yaxis: { ticks: [], min: 0 },
			colors: ["#25a1d6", "#3dc10b", "#545454" ],
			grid: { borderWidth: 0 }
	});
	
	$.plot($('#heartrate'), [{
			data: heartrate,
			lines: {
				show: true, 
				fill: true, 
				fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } 
			}
		}, {
			data: [[22, avghr]], 
			yaxis: 2,
			bars: { 
				show: true, 
				lineWidth: 1, 
				fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
			}
		}, {
			data: [[24, my_comps_hr]], 
			yaxis: 2,
			bars: { 
				show: true, 
				lineWidth: 1, 
				fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[26, all_comps_hr]], 
				yaxis: 2,
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: {colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}], 
			options
		)
		
	 	$.plot($('#fullsize_chart'), [ {
				data: heartrate_big, 
				lines: {
					show: true, 
					fill: true, 
					fillColor: { colors: [{ opacity: 0 }, { opacity: 0.1 }] } 
				}
			}],
			full_size_options)


    
	$.plot( $("#distance"), [{
				data: [[distance, .8]],
	            bars: { 
					horizontal: true, 
					show: true, 
					lineWidth: 1, 
					fillColor: { 
						colors: [{ opacity: 0.2 }, { opacity: 1 }] 
					} 
				}
			}, {
				data: [[my_comps_distance, .4]],
	            bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }  }
			},
			{
				data: [[all_comps_distance, 0.0]],
		        bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }  }
			}], {
	        xaxis: { ticks: [], min: 0 },
	        yaxis: { ticks: [], min: 0 },
			colors: ["#25a1d6", "#3dc10b", "#545454" ],
			grid: { borderWidth: 0 }
	});


	//  -------------------------

	


	 	$.plot($('#elevation'), [ {
			data: elevation,
			lines: {
				show: true, 
				fill: true, 
				fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } 
			}
		}, {
				data: [[22, gain]], 
				yaxis: 2,
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[24, my_comps_elevation]], 
				yaxis: 2,
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[26, all_comps_elevation]],
				yaxis: 2,
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
				yaxis: 2,
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[24, my_comps_speed]], 
				yaxis: 2,
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}, {
				data: [[26, all_comps_speed]], 
				yaxis: 2,
				bars: { 
					show: true, 
					lineWidth: 1, 
					fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } 
				}
			}], 
			options)
	 	


 // ---------------------

	// $.plot( $("#recent_workouts"), [{
	// 			data: [[duration, .8]],
	//             bars: { 
	// 				horizontal: true, 
	// 				show: true, 
	// 				lineWidth: 1, 
	// 				fillColor: { 
	// 					colors: [{ opacity: 0.2 }, { opacity: 1 }] 
	// 				} 
	// 			}
	// 		}, {
	// 			data: [[my_comps_duration, .4]],
	//             bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }  }
	// 		},
	// 		{
	// 			data: [[all_comps_duration, 0.0]],
	// 	        bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }  }
	// 		}], {
	//         xaxis: { ticks: [], min: 0 },
	//         yaxis: { ticks: [], min: 0 },
	// 		colors: ["#25a1d6", "#3dc10b", "#545454" ],
	// 		grid: { borderWidth: 0 }
	// });
	// 


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
});