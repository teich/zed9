$(document).ready(function() {

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