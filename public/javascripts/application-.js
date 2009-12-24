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
		case "cals": unit = "kCal"; break;
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
	colors: ["#25a1d6", "#25a1d6", "#3dc10b", "#545454"],
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

var summary_stats_bar_options = {
	show: true, 
	barWidth: 0.9,
	lineWidth: 1, 
	fillColor: { colors: [{ opacity: 1 }, { opacity: 0.6 }] }
};

var summary_stats_line_options = {
	show: true, 
	fill: false, 
	fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] }
};

var weight_graph_line_options = {
	show: true, 
	fill: true, 
	fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] }
};

var usage_bar_options = { 
	horizontal: true, 
	show: true, 
	lineWidth: 1, 
	barWidth: 1,
	fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }
};

var usage_options = {
	grid: { borderWidth: 0, tickColor: "white" },
	colors: ["#3dc10b", "#25a1d6"],
	shadowSize: 1,
	xaxis: { ticks: [], labels: [], min: 0, max: 100 },
	yaxis: { ticks: [], labels: [], min: 0, max: 1, autoscaleMargin: 0 },
	stack: true
};

var sparkbar_options = jQuery.extend(true, {}, options);
	sparkbar_options.xaxis.min = 0;
	sparkbar_options.yaxis.min = 0;
	sparkbar_options.colors = ["#25a1d6", "#3dc10b", "#545454"];

var line_options = { show: true, fill: true, fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } };
var end_bar_options = { show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } };
var first_bar_options = { horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }};
var other_bar_options = jQuery.extend(true, {}, first_bar_options);
other_bar_options.barWidth = 0.2;

// Pass in a JSON object, and draw based on that data.
function draw_dashboard_graph(data) {
	var workouts = data.user.workouts;
	
	function dashboard_tooltip(event, pos, item) {
		var unit = "seconds";
		
		if (item) {
			var previousPoint = [];
			if (previousPoint != item.datapoint) {
				previousPoint = item.datapoint;

				$("#bar_tooltip").remove();
				var x = item.datapoint[0].toFixed(0);
				var y = item.datapoint[1].toFixed(0);
				var d = new Date(workouts[x].json_date * 1000);
				var m_names = ["", "January", "February", "March",
				"April", "May", "June", "July", "August", "September",
				"October", "November", "December"];
				var display_date = m_names[d.getMonth() + 1] + " " + d.getDate() + ", " + d.getFullYear();
				var name = workouts[x].name;
				var activity_name = workouts[x].activity_name;
				var tip_text = "<span class='tooltip_extra_info'>" + activity_name + ":</span><br>"; 
				tip_text += name + "<br><span class='tooltip_extra_info'>" + display_date + "<br>" + hms(y) + "h</span>";

				$('<div id="bar_tooltip" class="tooltip">' + tip_text + '</div>').css({
					top: pos.pageY+4,
					left: pos.pageX+4
					}).appendTo("body").fadeIn(100);
				}
			}
			else {
				$("#bar_tooltip").remove();
				previousPoint = null;
			}    
		}

		var duration = [];
		var date = [];

		var barsDisplayed = workouts.length > 12 ? 12 : workouts.length;
		var last = workouts.length - barsDisplayed - 1;

		for (i = workouts.length -1; i > last; --i) {
			var d = new Date(workouts[i].json_date * 1000);
			var display_date = d.getMonth() + 1 + "/" + d.getDate();
			var horizontal_offset = i + 0.45;
			duration.push([i, workouts[i].duration]);
			date.push([horizontal_offset, display_date]);
		}

		function timeFormater(val, axis) {

			function checkTime(i)
			{
			if (i<10) 
			  {
			  i="0" + i;
			  }
			return i;
			}

	    var d = new Date(val*1000);
	    return d.getUTCHours() + ":" + checkTime(d.getUTCMinutes());
		}
		
		var dashboard_options = {
			grid: { borderWidth: 0, tickColor: "white", hoverable: "yes", clickable: true, mouseActiveRadius: 48, markings: xAxis },
			xaxis: { ticks: date, labelWidth: 24},
			yaxis: { minTickSize: 0, tickFormatter: timeFormater },
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


	// Pass in a JSON object, and draw based on that data for summary stats on dashboard
	function draw_dashboard_summary_graph(data) {
		var weekly_workout_hours = data.user.json_hours_per_week;
		// var top_activities = data.user.top_activities;

		var summary_stats_graph_options = {
			grid: { borderWidth: 0, tickColor: "white", hoverable: "yes", mouseActiveRadius: 12, markings: xAxis },
			xaxis: { ticks: data.user.json_weeks_labels, labelWidth: 24 },
			yaxis: { min: 0 },
			y2axis: { min: 0, minTickSize: 1, tickDecimals: 0 },
			colors: ["#ffa200", "#25a1d6"],
			shadowSize: 1,
			legend: {
					    show: true,
					    labelBoxBorderColor: null,
					    noColumns: 4,
					    position: "sw",
					    margin: [-15, -20],
					    backgroundColor: null,
					    backgroundOpacity: 0,
					    container: null
					  }
		};

		function summary_stats_tooltip(event, pos, item) {
			var previousPoint = [];
			if (item) {
				if (previousPoint != item.datapoint) {
					previousPoint = item.datapoint;
		
					$("#summary_stats_tooltip").remove();
					var x = pos.pageX
					var y = pos.pageY
					var count = item.datapoint[1];
					var tip_text = "<span class='tooltip_extra_info'>In the week starting starting "+ data.user.json_weeks_labels[item.dataIndex][1]+":<br>";
					tip_text += "You worked out </span>" + data.user.json_workouts_per_week[item.dataIndex][1] + " times</span><br>";
					tip_text += "<span class='tooltip_extra_info'>For a total of</span> " + hms(weekly_workout_hours[item.dataIndex][1]*3600) + " </span>hours</span>";
	
					$('<div id="summary_stats_tooltip" class="tooltip">' + tip_text + '</div>').css({
						top: pos.pageY+4,
						left: pos.pageX+4
						}).appendTo("body").fadeIn(100);
					}
				}
				else {
					$("#summary_stats_tooltip").remove();
					previousPoint = null;
				}    
			}

		var summary_data = [];
		summary_data.push( { data: data.user.json_workouts_per_week, yaxis: 2, bars: summary_stats_bar_options });
		summary_data.push({ data: weekly_workout_hours, lines: summary_stats_line_options });
		$.plot($('#summary_stats_graph'), summary_data, summary_stats_graph_options);
		$("#summary_stats_graph").bind("plothover", summary_stats_tooltip);
	}



	// Pass in a JSON object, and draw based on that data for summary stats on dashboard
	function draw_weight_graph(data) {

		var weights = data.user.json_weights;
		var weight_graph_options = {
			grid: { borderWidth: 0, tickColor: "white", hoverable: "yes", mouseActiveRadius: 12, markings: xAxis },
			xaxis: { mode: "time", timeformat: "%m/%d", labelWidth: 24 },
			yaxis: { minTickSize: 1, tickDecimals: 0, autoscaleMargin: 0.2 },
			colors: ["#25a1d6"],
			shadowSize: 1,
			legend: {show: false, container: null}
		};

		function weight_tooltip(event, pos, item) {
			var previousPoint = [];
			if (item) {
				if (previousPoint != item.datapoint) {
					previousPoint = item.datapoint;
		
					$("#summary_stats_tooltip").remove();
					var x = pos.pageX
					var y = pos.pageY
					var count = item.datapoint[1];
					var tip_text = weights[item.dataIndex][1] + "<span class='tooltip_extra_info'>lbs</span>";
			
					$('<div id="summary_stats_tooltip" class="tooltip">' + tip_text + '</div>').css({
						top: pos.pageY+4,
						left: pos.pageX+4
						}).appendTo("body").fadeIn(100);
					}
				}
				else {
					$("#summary_stats_tooltip").remove();
					previousPoint = null;
				}    
			}

		var weight_data = [];
		weight_data.push({ data: weights, lines: weight_graph_line_options, points: {show: true, radius: 3 } });
		$.plot($('#weight_graph'), weight_data, weight_graph_options);
		$("#weight_graph").bind("plothover", weight_tooltip);
	}


function workout_page_graphs(data) {
	function full_tooltip(event, pos, item) {
		// TODO: units are now dependent on data
		//var unit = '<span class="tooltip_unit">bpm</span>';
		if (item) {
			var previousPoint = [];
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

		// TODO: Handle units correctly
		// This hack converts everything to imperial

		workout.elevation *= 3.28;
		my_comps.elevation *= 3.28;
		all_comps.elevation *= 3.28;

		workout.distance *= 0.000621371192;
		my_comps.distance *= 0.000621371192;
		all_comps.distance *= 0.000621371192;

		$(".sparkline").each(function() {
			$.plot($(this), [
			{ data: workout["json_" + this.id], lines: line_options },
			{ data: [[22, workout[this.id]]], yaxis: 2, bars: end_bar_options },
			{ data: [[24, my_comps[this.id]]], yaxis: 2, bars: end_bar_options },
			{ data: [[26, all_comps[this.id]]], yaxis: 2, bars: end_bar_options }
			], options);
		});

		// $(".sparkbar").each(function(i) {
		// 	$.plot($(this), [
		// 	{ data: [[workout[this.id], 0.8]], bars: first_bar_options },
		// 	{ data: [[my_comps[this.id], 0.4]], bars: other_bar_options },
		// 	{ data: [[all_comps[this.id], 0.0]], bars: other_bar_options }
		// 	], sparkbar_options);
		// });

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
			} else if (this.id == 'cals') {
				data1 = workout.cals;
				data2 = my_comps.cals;
				data3 = all_comps.cals;
				unit = id_to_unit(this.id);
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
				
	function get_workout_values(workout) {
		// Get values
		var start_time = $("input#workout_start_time_string").val();
		var end_time = $("input#workout_end_time_string").val();
		var duration = $("input#workout_duration").val();
		var distance = $("input#workout_distance").val();
		var elevation = $("input#workout_elevation").val();
		 
		// Set Date
		if (start_time != "") {
			var z = start_time.split(" ");
			var date = z[0].split("-");
			var time = z[1].split(":");	
			var y = date[0];
			var m = date[1];
			var d = date[2];
			var a = "";
			var h = time[0];
			if (h > 12 ) {
				a = "PM";
				h = h - 12;
			} else a = "AM";
			var min = time[1];
			if (min < 10) min = "0" + min;
			$("input#start_date").val(m + "/" + d  + "/" + y);
			$("input#start_clock").val(h + ":" + min + a);

		}
		else {
			$("input#start_date").val("MM/DD/YYYY");
			$("input#start_clock").val("H:M");
		}		

		// Duration
		if (duration != "") {
			var millisec = duration * 1000;
			var date = new Date(millisec);
			var offset = date.getTimezoneOffset() * 60000;
			var corrected = date.setMilliseconds(date.getMilliseconds() + offset);
			var dur = new Date(corrected);
			var h = dur.getHours();
			var m = dur.getMinutes();
			var s = dur.getSeconds();
			if (m < 10) m = "0" + m;
	    if (s < 10) s = "0" + s;
			$("input#dur").val(h + ":" + m + ":" + s);
		}
		else {
			$("input#dur").val("H:M:S");			
		}
		
		// Distance
		if (distance != "") {
			var miles = (distance * 0.000621371192).toFixed(1);
			$("input#miles").val(miles);
		}
		else {
			$("input#miles").val("");
		}
		
		// Elevation
		if (elevation != "") {
			var feet = (elevation * 3.2808399).toFixed(1);
			$("input#feet").val(feet);
		}
		else {
			$("input#feet").val("");
		}
	}

	$.extend(DateInput.DEFAULT_OPTS, {

	  stringToDate: function(string) {
	    var matches;
	    if (matches = string.match(/^(\d{2,2})\/(\d{2,2})\/(\d{4,4})$/)) {
	      return new Date(matches[3], matches[1]-1, matches[2]);
	    } else {
	      return null;
	    };
	  },
  
	  dateToString: function(date) {
	    var month = (date.getMonth() + 1).toString();
	    var dom = date.getDate().toString();
	    if (month.length == 1) month = "0" + month;
	    if (dom.length == 1) dom = "0" + dom;
	    return month + "/" + dom + "/" + date.getFullYear();
	  }
	});

	function calculate_start() {
    var matches;
		var calculated_start;
		var start_date = $("input#start_date").val();
		var start_time = ($("input#start_clock").timeEntry('getTime'));
		var start_h = start_time.getHours();
		var start_m = start_time.getMinutes();
    if (matches = start_date.match(/^(\d{2,2})\/(\d{2,2})\/(\d{4,4})$/)) {
			calculated_start = new Date(matches[3], matches[1] - 1, matches[2], start_h, start_m);
		}
		$("input#workout_start_time_string").val(calculated_start);
	}
	
	function calculate_duration() {
		var d = $("input#dur").timeEntry('getTime');
		d.setDate(1);
		d.setMonth(0);
		d.setYear(1970);
		var offset = d.getTimezoneOffset() * 60;
		var dur = d.getTime()/1000 - offset;
		$("input#workout_duration").val(dur);
	}

	function calculate_end() {
		var start = Date.parse($("input#workout_start_time_string").val());
		var dur = ($("input#workout_duration").val())*1000;
		var end_in_ms =  start + dur;
		var end = new Date(end_in_ms);
		$("input#workout_end_time_string").val(end);
	}

	function convert_distance() {
		var distance = $("input#miles").val();
		if (distance == "") { 
			$("input#workout_distance").val("");
		} else {
			meters = (distance * 1609.344).toFixed(1);
			$("input#workout_distance").val(meters);
		}
	} 
	
	function convert_elevation() {
		var e = $("input#feet").val();
		if (e == "") { 
			$("input#workout_elevation").val("");
		} else {
			var m =  (e * 0.3048).toFixed(1);
			$("input#workout_elevation").val(m);
		}
	}

	function calculate_values() {
		calculate_start();
		calculate_duration();
		calculate_end();
		convert_distance();
		convert_elevation();
	}
	
	function miles_to_meters(miles) {
		return (miles * 1609.344).toFixed(1);
	}
	
	function meters_to_miles(meters) {
		return (meters / 1609.344).toFixed(1);
	}
	
	function set_journal_entry_values() {
		var date = $("input#journal_entry_entry_date").val();
		
		if (date == "") {
			var now = new Date();
	    var month = (now.getMonth() + 1).toString();
	    var dom = now.getDate().toString();
	    if (month.length == 1) month = "0" + month;
	    if (dom.length == 1) dom = "0" + dom;
			var today = month + "/" + dom + "/" + now.getFullYear();
			$("input#journal_entry_entry_date").val(today);			
		}
		else {
			var split = date.split("-")
			var month = split[1];
			var day = split[2];
			var year = split[0];
			var formatted = month + "/" + day + "/" + year;
			$("input#journal_entry_entry_date").val(formatted);
		}
	}	
	
	function set_gear_values() {
		var date = $("input#gear_purchase_date").val();
		
		if (date == "") {
			var now = new Date();
	    var month = (now.getMonth() + 1).toString();
	    var dom = now.getDate().toString();
	    if (month.length == 1) month = "0" + month;
	    if (dom.length == 1) dom = "0" + dom;
			var today = month + "/" + dom + "/" + now.getFullYear();
			$("input#gear_purchase_date").val(today);			
		}
		else {
			var split = date.split("-")
			var month = split[1];
			var day = split[2];
			var year = split[0];
			var formatted = month + "/" + day + "/" + year;
			$("input#gear_purchase_date").val(formatted);
		}

		var distance_max = $("input#gear_distance_max").val();
		if (distance_max != "") {
			var distance_in_miles = Math.round(meters_to_miles(distance_max));
			$("input#miles").val(distance_in_miles);
			}		

		var time = Math.round( ($("input#gear_hours_max").val()) / 3600 );
		$("input#hours").val(time);

	}	
	
	function convert_distance_max() {
		var distance = $("input#miles").val();
		if (distance == "") { 
			$("input#gear_distance_max").val("");
		} else {
			var meters = miles_to_meters(distance);
			$("input#gear_distance_max").val(meters);
		}
	} 
	
	function convert_hours_max() {
		var hours = $("input#hours").val();
		if (hours == "") { 
			$("input#gear_hours_max").val("");
		} else {
			var seconds = hours * 3600;
			$("input#gear_hours_max").val(seconds);
		}
	} 
	
	function draw_gear_usage() {

		$(".usage_bar").each(function() {
			var data = $(this).attr("data");
			// var dist_max = $(this).attr("dist_max");

			$.plot($(this), [
			{ data: [[100, 0]], bars: usage_bar_options },
			{ data: [[data, 0]], bars: usage_bar_options },
			], usage_options);
		});
		
	}
	
	function draw_dashboard_global_stats(data) {
		
		var my_ave_dur = data.user.json_global_comps.my_ave_daily_exercise;
		var global_ave_dur = data.user.json_global_comps.ave_daily_exercise;
		
		$(".sparkbar").each(function() {
			var first_bar_options = { horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }};
			var other_bar_options = jQuery.extend(true, {}, first_bar_options);
			other_bar_options.barWidth = 0.2;

			$.plot($(this), [
			{ data: [[my_ave_dur, 0.8]], bars: first_bar_options },
			{ data: [[global_ave_dur, 0.4]], bars: other_bar_options },
			], sparkbar_options);
		});	
		
		$(".stat").each(function() {
			var tip = '<div class="stat">';
			var unit = 0;

			tip += '<p class="comp_this_workout"><span class="value">';
			tip += my_ave_dur;
			tip += '</span><span class="unit">' + h + '</span> per day</p>';
			tip += '<p class="comp_my_activity"><span class="value">';
			tip += global_ave_dur + '</span><span class="unit">';
			tip += h + '</span> daily average exercise for all users</p>';

			$(this).qtip({
				content: tip,
				show: 'mouseover',
				hide: { when: 'mouseout', fixed: true },
				position: { target: $(this).children('.number'), corner: { tooltip: 'topLeft', target: 'topLeft' }, adjust: { x: 0, y: -5 } },
				style: tooltip_style
			});
		});
		
	}
	
	// THIS IS THE MAIN AREA.  CALLED ON PAGE LOAD

	$(document).ready(function() {

		// I'm using the .each selector really as a page identifier.  
		// TODO: be more overt in the naming.  i.e. #workout_page, #dashboard_page

		// Dashboard page graphs
		$('#recent_workouts_chart').each(function() {
			$.getJSON(jsURL, draw_dashboard_graph);
		});
		
		$('#dur_comps').each(function() {
			$.getJSON(jsURL, draw_dashboard_global_stats);
		});

		$('#summary_stats_graph').each(function() {
			$.getJSON(jsURL, draw_dashboard_summary_graph);
		});

		$('#weight_graph').each(function() {
			$.getJSON(jsURL, draw_weight_graph);
		});

		$('.usage_bar').each(function() {
			draw_gear_usage();			
		});

		// Workout page graphs
		$('#workout_stats').each(function() {
			$.getJSON(jsURL, workout_page_graphs);
		});

		$('#join_list').each(function() {
			$('.email_address').clearingInput();
		});

		// Workouts index table sorting, default to descending on date
		$('#workouts_index').each(function() {
			$("#workouts_index").tablesorter({
				sortList: [[2,1]]
			}); 
		});
		
		// Device comparison table sorting 
		$("#device_grid").each(function() {
			$("#device_grid").tablesorter({
				sortList: [[12, 1]],
				headers: { 
					1: { sorter: false }
				}
			}); 
		}); 

		// Dismiss flash message
		$('#flash').click(function() { 
			$(this).slideToggle('medium');
		});

		// Menu of nearby workouts
		$('#select_axes').hide();  
		$('#workouts_nearby_link').bind("click", function() {
			$('#nearby_workouts_list_container').slideToggle('fast');
			$(this).toggleClass('show_options');	
		});
		
		// Close graph options if click on x in corner
		$('#select_axes .close').click(function() {
			$('#nearby_workouts_list_container').slideToggle('fast');
			$('#workouts_nearby_link').toggleClass('show_options');
		});


		// Close graph options if click anywhere outside selection window
		$(window).bind('click', function(ev) {
		  if (!($(ev.target).is('#workouts_nearby_wrapper') || $(ev.target).parents('#workouts_nearby_wrapper').length )) {
				$('#nearby_workouts_list_container').slideUp('fast');
				$('#workouts_nearby_link').removeClass('show_options');	
			}
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
		$('.toggle').click(function() { 
			$(this).children('.more').slideToggle('fast');
			$(this).children('.activity_headline').toggleClass('open');
			$(this).toggleClass('open');
		});

		$($.date_input.initialize);

		$("#edit_workout").each(function() {

			// Tabs for add workout		
			$("#tabs").tabs();		

			// Get current workout values or defaults
			get_workout_values();

			// Date picker widget
		  $(".date_input").date_input();

			// Formatted time inputs for workout
			$(".time_input").timeEntry({initialField: 0});
			$(".duration_input").timeEntry({initialField: 0, show24Hours: true, showSeconds: true});

			// Accordion on new workout
	    $(".accordion").accordion({
				autoHeight: false, 
				collapsible: true, 
				active: false, 
				header: 'h4', 
				clearStyle: true, 
				icons: { header: 'toggle_closed', headerSelected: 'toggle_open' } 
			});

		});
		
		$('.form').each(function() {
			// Date picker widget
		  $(".date_input").date_input();
		})
		
		$('#journal_entry').each(function() {
			set_journal_entry_values();
		})

		$('#gear_form').each(function() {
			set_gear_values();
		})

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
