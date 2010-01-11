// Shows both the sparkline, and the tooltip
function plot_spark_graph(target, data, type) {

    // ----------------------
    // Settings for the various graphs
    // ----------------------
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
    	}};

    var flot_options = {
    	grid: { borderWidth: 0, tickColor: "white" },
    	xaxis: { ticks: [] },
    	yaxis: { ticks: [] },
    	y2axis: { ticks: [], autoscaleMargin: 0.2 },
    	colors: ["#25a1d6", "#25a1d6", "#3dc10b", "#545454"],
    	shadowSize: 1
    };

    var line_options = { 
        show: true, 
        fill: true, 
        fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } };

    var end_bar_options = { 
        show: true, 
        lineWidth: 1, 
        fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } };

    var flot_sparkbar = jQuery.extend(true, {}, flot_options);
    	flot_sparkbar.xaxis.min = 0;
    	flot_sparkbar.yaxis.min = 0;
    	flot_sparkbar.colors = ["#25a1d6", "#3dc10b", "#545454"];

    var first_bar_options = { 
    	horizontal: true, 
    	show: true, 
    	lineWidth: 1, 
    	fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }};

    var other_bar_options = jQuery.extend(true, {}, first_bar_options);
    	other_bar_options.barWidth = 0.2;    

    // ----------------------
    // Helper functions
    // ----------------------
    
    // This function just builds up the tool tip string
    // Take the data as a 3 element array, plus what unit to use
    // Special case if we're dealing with a time too.
    function spark_tooltip(values, unit) {
        // If the unit is h, it's a time, so convert it from seconds to a string
        if (unit == "h") {
            var bar = [hms(values[0]), hms(values[1]), hms(values[2])];
            values = bar;
        }
        
        var tip = '<div class="stat">';
        tip += '<p class="comp_this_workout"><span class="value">';
        tip += values[0];
        tip += '</span>';
        tip += '<span class="unit">' + unit + '</span> for this workout</p>';
        tip += '<p class="comp_my_activity"><span class="value">';
        tip += values[1] + '</span><span class="unit">';
        tip += unit + '</span> average for ' + '</p>';
        tip += '<p class="comp_activity"><span class="value">';
        tip += values[2] + '</span><span class="unit">';
        tip += unit + '</span> ZED9 average for ';
        tip += '</p></div >';
        return tip
    }
    
    if (type == "bar") {
        $.plot(target, [
			   { data: [[data["comps"][0], 0.8]], bars: first_bar_options },
			   { data: [[data["comps"][1], 0.4]], bars: other_bar_options },
			   { data: [[data["comps"][2], 0.0]], bars: other_bar_options }
			   ], flot_sparkbar);
    } else {
	    $.plot(target, [
        		{ data: data["data"], lines: line_options },
        		{ data: [[22, data["comps"][0]]], yaxis: 2, bars: end_bar_options },
        		{ data: [[24, data["comps"][1]]], yaxis: 2, bars: end_bar_options },
        		{ data: [[26, data["comps"][2]]], yaxis: 2, bars: end_bar_options }
        		], flot_options);
    }

    //  Display the tooltip for the graph
    $(target).parents(".stat").each(function() {
       $(this).qtip({
               content: spark_tooltip(data["comps"], $(this).attr('unit')),
               show: 'mouseover',
               hide: { when: 'mouseout', fixed: true },
               position: { target: $(this).children('.number'), corner: { tooltip: 'topLeft', target: 'topLeft' }, adjust: { x: 0, y: -5 } },
               style: tooltip_style
           }); 
    });
}


function plot_large_graph(target, data) {
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
	
	var line_options = { show: true, fill: true, fillColor: { colors: [{ opacity: 0 }, { opacity: 0.1 }] }};
	
	function getFullSizeOptions(id1, id2) {
		var base_options = {
			grid: { borderWidth: 0, tickColor: "white", hoverable: "yes", mouseActiveRadius: 36, markings: axes },
			colors: ["#25a1d6", "#ffa200", "#545454"],
			shadowSize: 1,
			xaxis: { mode: "time", timeformat: "%h:%M", minTickSize: [10, "minute"] },
			selection: { mode: "xy" }
		};

		// Manual check right now for the only thing that requires a different axis
		// if (id1 == "json_speed_big" && workout.activity.pace) {
			// base_options.yaxis = { mode: "time", timeformat: "%M:%S" };
		// }
		if (id2) {
			base_options.y2axis = {};
			base_options.grid = { borderWidth: 0, tickColor: "white", hoverable: "yes", mouseActiveRadius: 36, markings: axes2 };
		}
		// if (id2 == "json_speed_big" && workout.activity.pace) {
			// base_options.y2axis = { mode: "time", timeformat: "%M:%S" };
		// }
		return base_options;
	}

	function plotGraphSelected() {
		$("#y1_axis_options").find("input:checked").each(function () {
			leftkey = $(this).attr("value");
		});
		$("#y2_axis_options").find("input:checked").each(function () {
			rightkey = $(this).attr("value");
		});
		if (leftkey && data[leftkey]) {
			$("#y1_axis_label").html($(this).attr("display_y1"));
			// graph_data = formatData(leftkey);
		}
		if (rightkey && data[rightkey]) {
			$("#y2_axis_label").html($(this).attr("display_y2"));
			// graph_data2 = formatData(rightkey);
		}

		$('.none').click(function() {
			$("#y2_axis_label").hide();
		});

		$('.label').click(function() {
			$("#y2_axis_label").show();
		});

		full_size_options = getFullSizeOptions(leftkey, rightkey);

		if (rightkey && data[rightkey].length > 1) {
			$.plot(target, [
					{ data: data[leftkey], lines: line_options},
					{ data: data[rightkey], lines: line_options, yaxis: 2}
				], full_size_options);
		} else {
			$.plot(target, [{ data: data[leftkey], lines: line_options}], full_size_options)
		}
	}
	
	$("#y1_axis_options").find("input").click(plotGraphSelected);
	$("#y2_axis_options").find("input").click(plotGraphSelected);

	plotGraphSelected();
	$(".big_visualization").bind("plothover", full_tooltip);
	

}


$(document).ready(function() {
	$(".sparkline").each(function() {
		var self = $(this);
		var type = $(this).attr('spark-type');
        $.getJSON($(this).attr('data-src'),
            function(data) { plot_spark_graph(self,data,type) }
        );
    });

	$(".big_visualization").each(function() { 
		var self = $(this);
		$.getJSON($(this).attr('data-src'), 
			function(data) { plot_large_graph(self,data) }
		);
	});
	
	// Big graph selector field
	$('#options_link').bind("click", function() {
		$('#select_axes').slideToggle('fast');
		$(this).toggleClass('show_options');	
	});
	
	// Nearby workouts
	$('#select_axes').hide();  
	$('#workouts_nearby_link').bind("click", function() {
		$('#nearby_workouts_list_container').slideToggle('fast');
		$(this).toggleClass('show_options');	
	});

	// Close graph options if click on x in corner
	$('#select_axes .close').click(function() {
		$('#nearby_workouts_list_container').slideToggle('fast');
		$('#select_axes').slideToggle('fast');
		$('#options_link').toggleClass('show_options');		
		$('#workouts_nearby_link').toggleClass('show_options');
	});


	// Close graph options if click anywhere outside selection window
	$(window).bind('click', function(ev) {
	  if (!($(ev.target).is('#workouts_nearby_wrapper') || $(ev.target).parents('#workouts_nearby_wrapper').length )) {
			$('#nearby_workouts_list_container').slideUp('fast');
			$('#workouts_nearby_link').removeClass('show_options');	
		}
	  if (!($(ev.target).is('#graph_options_wrapper') || $(ev.target).parents('#graph_options_wrapper').length )) {
			$('#select_axes').slideUp('fast');
			$('#options_link').removeClass('show_options');	
		}

	});

});