// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

    var workoutURL = "/workouts/" + WORKOUT_ID + ".js"

    var options = {
        grid: { borderWidth: 0 },
        xaxis: { ticks: [] },
        yaxis: { ticks: [] },
        y2axis: { ticks: [], autoscaleMargin: .2 },
        colors: ["#25a1d6", "#3dc10b", "#545454"],
        shadowSize: 1,
    };

    var bar_options = {
        grid: { borderWidth: 0 },
        xaxis: { ticks: [], min: 0 },
        yaxis: { ticks: [], min: 0 },
        colors: ["#25a1d6", "#3dc10b", "#545454"],
        shadowSize: 1,
    };

    function axes(axes) {
        var markings = [];
        var y = axes.yaxis.min;
        var x = axes.xaxis.min;
        markings.push({ yaxis: { from: y, to: y }, color: "#d9d9d9", lineWidth: 1 }, { xaxis: { from: x, to: x }, color: "#d9d9d9", lineWidth: 1 } );
        return markings;
    }

    var full_size_options = {
		grid: { borderWidth: 0, borderColor: "#d9d9d9", tickColor: 'transparent', hoverable: "yes", mouseActiveRadius: 48, markings: axes },
		// crosshair: { mode: "x", color: '#d9d9d9' },
        colors: ["#25a1d6", "#3dc10b", "#545454"],
        shadowSize: 1,
        xaxis: { mode: "time", timeformat: "%h:%M", minTickSize: [15, "minute"] },
        yaxis: { tickSize: 20 },
		selection: { mode: "xy" }
	};

	// All the data for our workout pages comes from JSON.  Just wrapping the loops in the JSON call
	// TODO: Only call this on the workout page.  Search for some class I suppose.
    $.getJSON(workoutURL, function(json) {
        workout = json.workout
        all_comps = json.workout.json_comps.all_comps;
        my_comps = json.workout.json_comps.my_comps;

		// TODO: Handle units correctly
		// This hack converts everything to imperial
		workout.speed *= 2.23693629
		all_comps.speed *= 2.23693629
		my_comps.speed *= 2.23693629
		
		workout.elevation *= 3.28
		all_comps.elevation *= 3.28
		my_comps.elevation *= 3.28
		
		workout.distance *= 0.000621371192
		all_comps.distance *= 0.000621371192
		my_comps.distance *= 0.000621371192
		

		// Iterate over all the sparklines, and flot them.
        $(".sparkline").each(function(i) {
            $.plot($(this), [{
                data: workout["json_" + this.id],
                lines: { show: true, fill: true, fillColor: { colors: [{ opacity: 0 }, { opacity: 0.2 }] } }
            },
            {
                data: [[22, workout[this.id]]],
                yaxis: 2,
                bars: { show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } }
            },
            {
                data: [[24, my_comps[this.id]]],
                yaxis: 2,
                bars: { show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } }
            },
            {
                data: [[26, all_comps[this.id]]],
                yaxis: 2,
                bars: { show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 1 }, { opacity: 0.4 }] } }
            }], options)
        });

		// Iterate over all the sparkbars, and flot them.
		$(".sparkbar").each(function(i) {
	       $.plot($(this), [{
	            data: [[workout[this.id], .8]],
	            bars: { horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] }}
	        },
	        {
	            data: [[my_comps[this.id], .4]],
	            bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] } }
	        },
	        {
	            data: [[all_comps[this.id], 0.0]],
	            bars: { barWidth: .2, horizontal: true, show: true, lineWidth: 1, fillColor: { colors: [{ opacity: 0.2 }, { opacity: 1 }] } }
	        }], bar_options)
        });


		// Fullsize chart
        $.plot($('#spark_fullsize_chart'), [{
            data: workout.json_heartrate_big,
            lines: { show: true, fill: true, fillColor: { colors: [{ opacity: 0 }, { opacity: 0.1 }] } }
        }],
        full_size_options)


		// Fullsize chart tooltip
			
	    function showTooltip(x, y, contents) {
	        $('<div id="tooltip">' + contents + '</div>').css( {
	            position: 'absolute',
	            display: 'none',
	            top: y - 41,
	            left: x + 1,
	            border: '1px solid #d9d9d9',
	            padding: '8px',
				'color': '#25a1d6',
				'font-size': '18px',
				'font-weight': 500,
	            'background-color': '#f0f0f0',
	            opacity: .9,
				'-moz-border-radius-bottomleft': '5px',
				'-moz-border-radius-bottomright': '5px',
				'-moz-border-radius-topleft': '5px',
				'-moz-border-radius-topright': '5px',
				'border-radius-bottomleft': '5px',
				'border-radius-bottomright': '5px',
				'border-radius-topleft': '5px',
				'border-radius-topright': '5px'
	        }).appendTo("body").fadeIn(200);
	    }
	    
		var unit = '<span style="font-size: 14px; font-weight: 100">bpm</span>'
	
	    var previousPoint = null;
	
	    $("#spark_fullsize_chart").bind("plothover", function (event, pos, item) {
	        // $("#x").text(pos.x.toFixed(2));
	        // $("#y").text(pos.y.toFixed(2));
            if (item) {
                if (previousPoint != item.datapoint) {
                    previousPoint = item.datapoint;
    
                    $("#tooltip").remove();
                    var x = item.datapoint[0].toFixed(2),
                        y = item.datapoint[1].toFixed(0);
    
                    showTooltip(item.pageX, item.pageY, y + unit);
                }
            }
            else {
                $("#tooltip").remove();
                previousPoint = null;            
            }
	    });	    


		// // Tooltip for x axis position
		// 
		// function updateLegend() {
		// 	        updateLegendTimeout = null;
		// 
		// 	        var pos = latestPosition;
		// 
		// 	        var axes = plot.getAxes();
		// 	        if (pos.x < axes.xaxis.min || pos.x > axes.xaxis.max ||
		// 	            pos.y < axes.yaxis.min || pos.y > axes.yaxis.max)
		// 	            return;
		// 
		// 	        var i, j, dataset = plot.getData();
		// 	        for (i = 0; i < dataset.length; ++i) {
		// 	            var series = dataset[i];
		// 
		// 	            // find the nearest points, x-wise
		// 	            for (j = 0; j < series.data.length; ++j)
		// 	                if (series.data[j][0] > pos.x)
		// 	                    break;
		// 
		// 	            // now interpolate
		// 	            var y, p1 = series.data[j - 1], p2 = series.data[j];
		// 	            if (p1 == null)
		// 	                y = p2[1];
		// 	            else if (p2 == null)
		// 	                y = p1[1];
		// 	            else
		// 	                y = p1[1] + (p2[1] - p1[1]) * (pos.x - p1[0]) / (p2[0] - p1[0]);
		// 
		// 	            tooltip.eq(i)(content.replace(y.toFixed(0)));
		// 	        }
		// 	    }
		// 	    
		// 
		// Iterate over all the class "stat" and qtip them.
		
        $(".stat").each(function(i) {
			var tip = '<div class="stat">'
				tip += '<p class="comp_this_workout"><span class="value">' + Math.round(workout[this.id]*10)/10 + '</span>' + $(this).attr('unit') + ' for this workout</p>' 
				tip += '<p class="comp_my_activity"><span class="value">' + Math.round(my_comps[this.id]*10)/10 + '</span>' + $(this).attr('unit') + ' for your ' + workout.activity_name + '</p>'
				tip += '<p class="comp_activity"><span class="value">' + Math.round(all_comps[this.id]*10)/10 + '</span>' + $(this).attr('unit') + ' for ZED9 ' + workout.activity_name + '</p></div >'
						
		$(this).qtip({
			content: tip,
			show: 'mouseover',
			hide: { when: 'mouseout', fixed: true },
			position: { target: $(this).children(':last'), corner: { tooltip: 'topLeft', target: 'topLeft' }, adjust: { x: 0, y: -5 } },
			style: { width: 264, padding: 4, background: '#f0f0f0', color: '#545454', textAlign: 'left', border: { width: 1, radius: 8, color: '#f0f0f0' } }
			});
        });
    });
});