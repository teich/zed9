// Set up options for our pretty graphs
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
	
// ----------------------------
// Graphing
// ----------------------------
$(document).ready(function() {
	$('.sparkbar').each(function() {
        var self = $(this);
        $.getJSON($(this).attr('data-src'),
        function(data) {
            $.plot(self, [
				   { data: [[data["comps"][0], 0.8]], bars: first_bar_options },
				   { data: [[data["comps"][1], 0.4]], bars: other_bar_options },
				   { data: [[data["comps"][2], 0.0]], bars: other_bar_options }
				   ], flot_sparkbar);
            // self.bind("plothover", tooltiphover);
        });
    });

	$(".sparkline").each(function() {
		var self = $(this);
        $.getJSON($(this).attr('data-src'),
        function(data) {
		    $.plot(self, [
            		{ data: data["data"], lines: line_options },
            		{ data: [[22, data["comps"][0]]], yaxis: 2, bars: end_bar_options },
            		{ data: [[24, data["comps"][1]]], yaxis: 2, bars: end_bar_options },
            		{ data: [[26, data["comps"][2]]], yaxis: 2, bars: end_bar_options }
            		], flot_options);
	    });
	});
});