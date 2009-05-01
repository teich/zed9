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

    var full_size_options = {
				grid: { borderWidth: 0, borderColor: "#d9d9d9", tickColor: '#ffffff', hoverable: "yes", mouseActiveRadius: 24, },
        colors: ["#25a1d6", "#3dc10b", "#545454"],
        shadowSize: 1,
        xaxis: { tickSize: 30 },
        yaxis: { tickSize: 20 }
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

		// Iterate over all the class "stat" and qtip them.
        $(".stat").each(function(i) {
            $(this).qtip({
            	content: '<div class="stat"><p class="comp_this_workout"><span class="value">' + Math.round(workout[this.id]*10)/10 + '</span> ' + $(this).attr('unit') + ' for this ' + workout.activity_name + '</p> <p class="comp_my_activity"><span class="value">' + Math.round(my_comps[this.id]*10)/10 + '</span> ' + $(this).attr('unit') + ' average for all your ' + workout.activity_name + '</p> <p class="comp_activity"><span class="value">' + Math.round(all_comps[this.id]*10)/10 + '</span> ' + $(this).attr('unit') + ' average for everyones ' + workout.activity_name + '</p></div > ',
				show: 'mouseover',
				hide: { when: 'mouseout', fixed: true },
				position: { target: $(this).children(':last'), corner: { tooltip: 'topLeft', target: 'topLeft' }, adjust: { x: -4, y: -13 } },
				style: { width: 288, padding: 8, background: '#f0f0f0', color: '#545454', textAlign: 'left', border: { width: 1, radius: 8, color: '#f0f0f0' } }
            });
        });
    });
});