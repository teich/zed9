// GLOBAL VARIABLES
var jsURL = document.location.href + ".js";

function xAxis(value) {
	var markings = [];
	var y = value.yaxis.min;
	markings.push({ yaxis: { from: y, to: y }, color: "#d9d9d9", lineWidth: 1 });
	return markings;
}

summary_stats_bar_options = {
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

$(document).ready(function() {
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



})