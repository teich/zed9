function hms(secs) {
	var t = new Date(1970, 0, 1);
	t.setSeconds(secs);
	return t.toTimeString().substr(0, 8);
}

// This is for the small random stuff.  Bigger stuff, such as graphs and maps are in their own files!
$(document).ready(function() {
    
    $($.date_input.initialize);
	
	// Toggle view of bests on leaderboards
	$('div.more').hide();  
	$('.toggle').click(function() { 
		$(this).children('.more').slideToggle('fast');
		$(this).children('.activity_headline').toggleClass('open');
		$(this).toggleClass('open');
	});
	
	$('#join_list').each(function() {
		$('.email_address').clearingInput();
	});
	
	// Dismiss flash message
	$('#flash').click(function() { 
		$(this).slideToggle('medium');
	});
	
	// Workouts index table sorting, default to descending on date
	$('#workouts_index').each(function() {
		$("#workouts_index").tablesorter({
			sortList: [[2,1]]
		}); 
	});
	
	$('#journal_entry').each(function() {
		set_journal_entry_values();
	})

	$('#gear_form').each(function() {
		set_gear_values();
	})
	
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