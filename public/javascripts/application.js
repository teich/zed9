function hms(secs) {
	var t = new Date(1970, 0, 1);
	t.setSeconds(secs);
	return t.toTimeString().substr(0, 8);
}

// This is for the small random stuff.  Bigger stuff, such as graphs and maps are in their own files!
$(document).ready(function() {
    
    $($.date_input.initialize);
	
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
	
	// Date picker widget
	$('.form').each(function() {
	  $(".date_input").date_input();
	})
	
})