// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// CONSTANTS
var MPS_TO_MPH = 2.23693629;
var MIN_TO_MILLISEC = 3600000;
// END CONSTANTS

// GLOBAL VARIABLES
var jsURL = document.location.href + ".js";
var previousPoint = null;
// END GLOBAL VARIABLES

function hms(secs) {
	var t = new Date(1970, 0, 1);
	t.setSeconds(secs);
	return t.toTimeString().substr(0, 8);
}

function speed_to_pace(speed) {
	if (speed < 0.1) {
		return "00:00";
	}
	var pace = 60 / speed;
	var min = parseInt(pace, 10);
	var sec = ((pace % 1) * 60).toFixed(0);
	if (sec < 10) {
		sec = "0" + sec;
	}
	return min + ":" + sec;
}

function formatted_speed(mps, pace, metric) {
	// TODO: METRIC CHECKING
	if (!metric) {
		speed = mps * MPS_TO_MPH;
	}

	if (pace) {
		return speed_to_pace(speed);
	} else {
		return speed.toFixed(1);
	}

}

function id_to_unit(id, pace) {
	var unit = "";
	switch (id) {
		case "distance": unit = "miles"; break;
		case "speed": unit = pace ? "min/mile" : "mph"; break;
		case "elevation": unit = "ft"; break;
		case "hr": unit = "bpm"; break;
		case "duration": unit = "h"; break;
		default: unit = "ARG!";
	}
	return unit;
}

// HELPER FUNCTIONS
// Define global graph options

// x and y1 axes
function axes(value) {
	var markings = [];
	var y = value.yaxis.min;
	var x = value.xaxis.min;
	var x2 = value.xaxis.max;
	markings.push({ yaxis: { from: y, to: y }, color: "#d9d9d9", lineWidth: 1 }, { xaxis: { from: x, to: x }, color: "#25a1d6", lineWidth: 1 } );
	return markings;
}

// x, y1, and y2 axes
function axes2(value) {
	var markings = [];
	var y = value.yaxis.min;
	var x = value.xaxis.min;
	var x2 = value.xaxis.max;
	markings.push({ yaxis: { from: y, to: y }, color: "#d9d9d9", lineWidth: 1 }, { xaxis: { from: x, to: x }, color: "#25a1d6", lineWidth: 1 }, { xaxis: { from: x2, to: x2 }, color: "#ffa200", lineWidth: 1 } );
	return markings;
}

function xAxis(value) {
	var markings = [];
	var y = value.yaxis.min;
	markings.push({ yaxis: { from: y, to: y }, color: "#d9d9d9", lineWidth: 1 });
	return markings;
}

// END HELPER FUNCTIONS

var options = {
	grid: { borderWidth: 0, tickColor: "white" },
	xaxis: { ticks: [] },
	yaxis: { ticks: [] },
	y2axis: { ticks: [], autoscaleMargin: 0.2 },
	colors: ["#25a1d6", "#3dc10b", "#545454"],
	shadowSize: 1
};

var tooltip_style = {
	width: 336,
	padding: 4,
	background: '#f0f0f0',
	color: '#545454',
	textAlign: 'left',
	border: {
		width: 1,
		radius: 8,
		color: '#f0f0f0' 
	}
};


// Pass in a JSON object, and draw based on that data.
function draw_dashboard_graph(data) {
	function dashboard_tooltip(event, pos, item) {
		var unit = "seconds";
		if (item) {
			if (previousPoint != item.datapoint) {
				previousPoint = item.datapoint;

				$("#bar_tooltip").remove();
				var x = item.datapoint[0].toFixed(0);
				var y = item.datapoint[1].toFixed(0);
				var d = new Date(data[x].workout.json_date * 1000);
				var m_names = ["", "January", "February", "March",
				"April", "May", "June", "July", "August", "September",
				"October", "November", "December"];
				var display_date = m_names[d.getMonth() + 1] + " " + d.getDate() + ", " + d.getFullYear();
				var name = data[x].workout.name;
				var activity_name = data[x].workout.activity_name;
				var tip_text = "<span class='tooltip_extra_info'>" + activity_name + ":</span><br>"; 
				tip_text += name + "<br><span class='tooltip_extra_info'>" + display_date + "<br>" + hms(y) + "h</span>";

				$('<div id="bar_tooltip" class="tooltip">' + tip_text + '</div>').css({
					top: item.pageY + 8,
					left: item.pageX + 8
					}).appendTo("body").fadeIn(200);
				}
			}
			else {
				$("#bar_tooltip").remove();
				previousPoint = null;
			}    
		}

		var duration = [];
		var date = [];

		var barsDisplayed = data.length > 12 ? 12 : data.length;
		var last = data.length - barsDisplayed - 1;

		for (i = data.length -1; i > last; --i) {
			var d = new Date(data[i].workout.json_date * 1000);
			var display_date = d.getMonth() + 1 + "/" + d.getDate();
			duration.push([i, data[i].workout.duration]);
			date.push([i, display_date]);
		}

		var dashboard_options = {
			grid: { borderWidth: 0, tickColor: "white", hoverable: "yes", clickable: true, mouseActiveRadius: 48, markings: xAxis },
			xaxis: { ticks: date, labelWidth: 12 },
			yaxis: { ticks: [], autoscaleMargin: 0.2 },
			colors: ["#25a1d6"],
			shadowSize: 1
		};

		$.plot($('#recent_workouts_chart'), [{
			data: duration,
			bars: { show: true, barWidth: 0.9, lineWidth: 1, fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } }
			}], dashboard_options
		);

		$("#recent_workouts_chart").bind("plothover", dashboard_tooltip);
	}


function workout_page_graphs(data) {
	function full_tooltip(event, pos, item) {
		// TODO: units are now dependent on data
		//var unit = '<span class="tooltip_unit">bpm</span>';
		if (item) {
			if (previousPoint != item.datapoint) {
				previousPoint = item.datapoint;
				$("#fullsize_tooltip").remove();
				var x = item.datapoint[0].toFixed(2);
				var y = item.datapoint[1].toFixed(0);

				// This hack tells me it's a time. I know...
				if (y > 100000) {
					y = speed_to_pace(MIN_TO_MILLISEC / y);
				}
				key = (x / 10000).toFixed(0);
				point = z9map.pointsByRoundedTime[key];
				
				// Only try and update map, if we have a map!
				if (z9map.gmap) { 
					setCurrLoc(z9map, point.y, point.x); 
				}
				$('<div id="fullsize_tooltip" class="tooltip">' + y + '</div>').css( {
					top: item.pageY - 41,
					left: item.pageX + 1
					}).appendTo("body").fadeIn(200);
				}
			} else {
				$("#fullsize_tooltip").remove();
				previousPoint = null;            
			}
		}

		var workout = data.workout;
		var all_comps = workout.json_comps.all_comps;
		var my_comps = workout.json_comps.my_comps;

		// Just add the differences.  This jquery.Extend copies the object.
		var sparkbar_options = jQuery.extend(true, {}, options);
		sparkbar_options.xaxis.min = 0;
		sparkbar_options.yaxis.min = 0;

		// TODO: Handle units correctly
		// This hack converts everything to imperial

		workout.elevation *= 3.28;
		all_comps.elevation *= 3.28;
		my_comps.elevation *= 3.28;

		workout.distance *= 0.000621371192;
		all_comps.distance *= 0.000621371192;
		my_comps.distance *= 0.000621371192;

		$(".sparkline").each(function() {
			var line_options = { show: true, fill: true, fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } };
			var end_bar_options = { show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } };

			$.plot($(this), [
			{ data: workout["json_" + this.id], lines: line_options },
			{ data: [[22, workout[this.id]]], yaxis: 2, bars: end_bar_options },
			{ data: [[24, my_comps[this.id]]], yaxis: 2, bars: end_bar_options },
			{ data: [[26, all_comps[this.id]]], yaxis: 2, bars: end_bar_options }
			], options);
		});

		$(".sparkbar").each(function(i) {
			// Our bars are almost identical, except that the additional bars are thinner.
			var first_bar_options = { horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }};
			var other_bar_options = jQuery.extend(true, {}, first_bar_options);
			other_bar_options.barWidth = 0.2;

			$.plot($(this), [
			{ data: [[workout[this.id], 0.8]], bars: first_bar_options },
			{ data: [[my_comps[this.id], 0.4]], bars: other_bar_options },
			{ data: [[all_comps[this.id], 0.0]], bars: other_bar_options }
			], sparkbar_options);
		});

	$(".big_visualization").each(function() { 
		function formatData(id) {
			var graph_data = [];
			
			if (id == "json_speed_big") {
				var temp = workout[id];
				for (var i = 0; i < temp.length; i++) {
					var x = temp[i][0];
					// TODO: metric/imperical support goes here
					var y = temp[i][1] * MPS_TO_MPH;
					if (workout.activity.pace) {
						// Special case the stopped situation.
						y = y < 1 ? null : MIN_TO_MILLISEC / y;
					}
					graph_data[i] = [x, y];
				}
			} else {
				graph_data = workout[id];
			}
			return graph_data;
		}
		
		function getFullSizeOptions(id1, id2) {
			var base_options = {
				grid: { borderWidth: 0, tickColor: "white", hoverable: "yes", mouseActiveRadius: 36, markings: axes },
				// crosshair: { mode: "x", color: '#d9d9d9' },
				colors: ["#25a1d6", "#ffa200", "#545454"],
				shadowSize: 1,
				xaxis: { mode: "time", timeformat: "%h:%M", minTickSize: [10, "minute"] },
				selection: { mode: "xy" }
			};
			// Manual check right now for the only thing that requires a different axis
			if (id1 == "json_speed_big" && workout.activity.pace) {
				base_options.yaxis = { mode: "time", timeformat: "%M:%S" };
			}
			if (id2) {
				base_options.y2axis = {};
				base_options.grid = { borderWidth: 0, tickColor: "white", hoverable: "yes", mouseActiveRadius: 36, markings: axes2 };
			}
			if (id2 == "json_speed_big" && workout.activity.pace) {
				base_options.y2axis = { mode: "time", timeformat: "%M:%S" };
			}
			return base_options;
		}
		
		function plotGraphSelected() {
			var graph_data = [];
			var graph_data2 = [];
			var full_size_options = {};
			var leftkey;
			var rightkey;
			var dataHash = {};
			$("#y1_axis_options").find("input:checked").each(function () {
				leftkey = $(this).attr("value");
			});
			$("#y2_axis_options").find("input:checked").each(function () {
				rightkey = $(this).attr("value");
			});
			if (leftkey && workout[leftkey]) {
				$("#y1_axis_label").html($(this).attr("display_y1"));
				graph_data = formatData(leftkey);
			}
			if (rightkey && workout[rightkey]) {
				$("#y2_axis_label").html($(this).attr("display_y2"));
				graph_data2 = formatData(rightkey);
			}

			$('.none').click(function() {
				$("#y2_axis_label").hide();
			});
				
			$('.label').click(function() {
				$("#y2_axis_label").show();
			});

			full_size_options = getFullSizeOptions(leftkey, rightkey);
			if (graph_data2.length > 1) {
				$.plot($('.big_visualization'), [
				{ data: graph_data, lines: { show: true, fill: true, fillColor: { colors: [{ opacity: 0 }, { opacity: 0.1 }] } }},
				{ data: graph_data2, lines: { show: true, fill: true, fillColor: { colors: [{ opacity: 0 }, { opacity: 0.1 }] } }, yaxis: 2}], 
				full_size_options);
			} else {
				$.plot($('.big_visualization'), [{ 
					data: graph_data, 
					lines: { show: true, fill: true, fillColor: { colors: [{ opacity: 0 }, { opacity: 0.1 }] } } 
				}],
				full_size_options);
			}

		}
			
		$("#y1_axis_options").find("input").click(plotGraphSelected);
		$("#y2_axis_options").find("input").click(plotGraphSelected);

		plotGraphSelected();
		$(".big_visualization").bind("plothover", full_tooltip);

	});

		$(".stat").each(function() {
			var tip = '<div class="stat">';
			var unit = 0;
			if (this.id == "duration") {
				data1 = hms(workout[this.id]);
				data2 = hms(my_comps[this.id]);
				data3 = hms(all_comps[this.id]);
				unit = id_to_unit(this.id);
			} else if (this.id == 'speed') {
				data1 = formatted_speed(workout[this.id], workout.activity.pace, false);
				data2 = formatted_speed(my_comps[this.id], workout.activity.pace, false);
				data3 = formatted_speed(all_comps[this.id], workout.activity.pace, false);
				unit = id_to_unit(this.id, workout.activity.pace);
			} else {
				data1 = workout[this.id].toFixed(1);
				data2 = my_comps[this.id].toFixed(1);
				data3 = all_comps[this.id].toFixed(1);
				unit = id_to_unit(this.id);
			}

			tip += '<p class="comp_this_workout"><span class="value">';
			tip += data1;
			tip += '</span><span class="unit">' + unit + '</span> for this workout</p>';
			tip += '<p class="comp_my_activity"><span class="value">';
			tip += data2 + '</span><span class="unit">';
			tip += unit + '</span> average for ' + workout.activity.name.toLowerCase() + '</p>';
			tip += '<p class="comp_activity"><span class="value">';
			tip += data3 + '</span><span class="unit">';
			tip += unit + '</span> ZED9 average for ' + workout.activity.name.toLowerCase() + '</p></div >';

			$(this).qtip({
				content: tip,
				show: 'mouseover',
				hide: { when: 'mouseout', fixed: true },
				position: { target: $(this).children('.number'), corner: { tooltip: 'topLeft', target: 'topLeft' }, adjust: { x: 0, y: -5 } },
				style: tooltip_style
			});
		});

		google.setOnLoadCallback(z9MapInit(data.workout.gis));

	}

	
	// THIS IS THE MAIN AREA.  CALLED ON PAGE LOAD
	$(document).ready(function() {


		// I'm using the .each selector really as a page identifier.  
		// TODO: be more overt in the naming.  i.e. #workout_page, #dashboard_page

		// Dashboard page graphs
		$('#recent_workouts_chart').each(function() {
			$.getJSON(jsURL, draw_dashboard_graph);
		});

		// Workout page graphs
		$('#workout_stats').each(function() {
			$.getJSON(jsURL, workout_page_graphs);
		});

		// Workouts index table sorting, default to descending on date
		$("#workouts_index").tablesorter({
			sortList: [[2, 1]],
			headers: { 
				0: { sorter: false },
				11: { sorter: false },
			}
		}); 

		// Device comparison table sorting 
		$("#device_grid").tablesorter({
			sortList: [[12, 1]],
			headers: { 
				1: { sorter: false }
			}
		}); 

		// Dismiss flash message
		$('#flash').click(function() { 
			$(this).slideToggle('medium');
		});

		// Graph options
		$('#select_axes').hide();  
		$('#options_link').bind("click", function() {
			$('#select_axes').slideToggle('fast');
			$(this).toggleClass('show_options');	
		});
		
		// Close graph options if click on x in corner
		$('#select_axes .close').click(function() {
			$('#select_axes').slideToggle('fast');
			$('#options_link').toggleClass('show_options');
		});


		// Close graph options if click anywhere outside selection window
		$(window).bind('click', function(ev) {
		  if (!($(ev.target).is('#graph_options_wrapper') || $(ev.target).parents('#graph_options_wrapper').length )) {
				$('#select_axes').slideUp('fast');
				$('#options_link').removeClass('show_options');	
			}
		});
		
		// Toggle view of bests on leaderboards
		$('div.more').hide();  
		$('div.leaderboard').click(function() { 
			$(this).children('.more').slideToggle('fast');
			$(this).toggleClass('open');
		});


		// Accordion on new workout
    $("#locating").accordion({ autoHeight: false }, { header: 'h4' }, { collapsible: true }, { active: false });
		
		$('.accordion_header').click(function() {
			$('.accordion_header_active').next('.accordion_content_active').removeClass('accordion_content_active');
		  $('.accordion_header_active').removeClass('accordion_header_active');
			$(this).next('.accordion_content').addClass('accordion_content_active');
			$(this).addClass('accordion_header_active');
		});
		
		// Workouts index row highlight on hover
		$('tr.newsfeed_workout_summary').hover(function() {
			$(this).children().addClass("highlight");
		},
		function() {
			$(this).children().removeClass("highlight");
		});

		// Guide row highlight on hover
		$('tr.model_details').hover(function() {
			$(this).children().addClass("highlight");
		},
		function() {
			$(this).children().removeClass("highlight");
		});

		// Notices
		$('.timed').each(function() {
			jQuery.noticeAdd({
				text: $(this).append().html(),
				stay: false,
				type: $(this).attr("type"),
				stayTime: 6000
			});
		});

		$('.sticky').each(function() {
			jQuery.noticeAdd({
				text: $(this).append().html(),
				stay: true,
				type: $(this).attr("type")
			});
		});

		$('.tip[title]').qtip({
			style: {
				background: '#f0f0f0',
				color: '#545454',
				padding: 4,
				textAlign: 'center',
				border: {
					width: 1,
					radius: 8,
					color: '#f0f0f0' 
				},
				tip: 'bottomLeft', 
			},
			position: { 
				corner: { 
					tooltip: 'bottomLeft', 
					target: 'topRight' 
				},
				adjust: { 
					screen: true,
					resize: true 
				} 
			},
		  show: 'mouseover',
			hide: { when: 'mouseout', fixed: true }
		});

	});
