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
    // convert_distance();
    // convert_elevation();
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
$(document).ready(function() {

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
	
});