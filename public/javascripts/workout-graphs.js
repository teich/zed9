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


$(document).ready(function() {
	$(".sparkline").each(function() {
		var self = $(this);
		var type = $(this).attr('spark-type');
        $.getJSON($(this).attr('data-src'),
            function(data) { plot_spark_graph(self,data,type) }
        );
    });
});