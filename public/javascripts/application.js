// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


$(document).ready(function() {

    var heartrate;
    var elevation;
    var speed;
    var myData;

    var compFields = ["heartrate", "elevation", "speed"];
    var workoutURL = "/workouts/" + WORKOUT_ID + ".js"

    var options = {
        grid: {
            borderWidth: 0
        },
        xaxis: {
            ticks: []
        },
        yaxis: {
            ticks: []
        },
        y2axis: {
            ticks: [],
            autoscaleMargin: .2
        },

        colors: ["#25a1d6", "#3dc10b", "#545454"],
        shadowSize: 1,
    };

    var bar_options = {
        grid: {
            borderWidth: 0
        },
        xaxis: {
            ticks: [],
            min: 0
        },
        yaxis: {
            ticks: [],
            min: 0
        },
        colors: ["#25a1d6", "#3dc10b", "#545454"],
        shadowSize: 1,
    };

    var full_size_options = {
        grid: {
            borderWidth: 0,
            borderColor: "#d9d9d9",
            tickColor: '#ffffff',
            hoverable: "yes",
            mouseActiveRadius: 24,
        },
        colors: ["#25a1d6", "#3dc10b", "#545454"],
        shadowSize: 1,
        xaxis: {
            tickSize: 30
        },
        yaxis: {
            tickSize: 20
        }
    };

    $.getJSON(workoutURL,
    function(json) {
        workout = json.workout
        all_comps = json.workout.json_comps.all_comps;
        my_comps = json.workout.json_comps.my_comps;





        //  -------------------------
        $.plot($("#spark_duration"), [{
            data: [[workout.duration, .8]],
            bars: {
                horizontal: true,
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 0.2
                    },
                    {
                        opacity: 1
                    }]
                }
            }
        },
        {
            data: [[my_comps.duration, .4]],
            bars: {
                barWidth: .2,
                horizontal: true,
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 0.2
                    },
                    {
                        opacity: 1
                    }]
                }
            }
        },
        {
            data: [[all_comps.duration, 0.0]],
            bars: {
                barWidth: .2,
                horizontal: true,
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 0.2
                    },
                    {
                        opacity: 1
                    }]
                }
            }
        }], {
            xaxis: {
                ticks: [],
                min: 0
            },
            yaxis: {
                ticks: [],
                min: 0
            },
            colors: ["#25a1d6", "#3dc10b", "#545454"],
            grid: {
                borderWidth: 0
            }
        });

        $.plot($('#spark_heartrate'), [{
            data: workout.json_heartrate,
            lines: {
                show: true,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 0
                    },
                    {
                        opacity: 0.2
                    }]
                }
            }
        },
        {
            data: [[22, workout.hr]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        },
        {
            data: [[24, my_comps.hr]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        },
        {
            data: [[26, all_comps.hr]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        }],
        options
        )

        $.plot($('#spark_fullsize_chart'), [{
            data: workout.json_heartrate_big,
            lines: {
                show: true,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 0
                    },
                    {
                        opacity: 0.1
                    }]
                }
            }
        }],
        full_size_options)



        $.plot($("#spark_distance"), [{
            data: [[workout.distance, .8]],
            bars: {
                horizontal: true,
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 0.2
                    },
                    {
                        opacity: 1
                    }]
                }
            }
        },
        {
            data: [[my_comps.distance, .4]],
            bars: {
                barWidth: .2,
                horizontal: true,
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 0.2
                    },
                    {
                        opacity: 1
                    }]
                }
            }
        },
        {
            data: [[all_comps.distance, 0.0]],
            bars: {
                barWidth: .2,
                horizontal: true,
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 0.2
                    },
                    {
                        opacity: 1
                    }]
                }
            }
        }], {
            xaxis: {
                ticks: [],
                min: 0
            },
            yaxis: {
                ticks: [],
                min: 0
            },
            colors: ["#25a1d6", "#3dc10b", "#545454"],
            grid: {
                borderWidth: 0
            }
        });


        //  -------------------------



        $.plot($('#spark_elevation'), [{
            data: workout.json_elevation,
            lines: {
                show: true,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 0
                    },
                    {
                        opacity: 0.2
                    }]
                }
            }
        },
        {
            data: [[22, workout.elevation]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        },
        {
            data: [[24, my_comps.elevation]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        },
        {
            data: [[26, all_comps.elevation]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        }],
        options)

        $.plot($('#spark_speed'), [{
            data: workout.json_speed,
            lines: {
                show: true,
                fill: true,
                fillColor: {
                    colors: [{
                        opacity: 0
                    },
                    {
                        opacity: 0.2
                    }]
                }
            }
        },
        {
            data: [[22, workout.speed]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        },
        {
            data: [[24, my_comps.speed]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        },
        {
            data: [[26, all_comps.speed]],
            yaxis: 2,
            bars: {
                show: true,
                lineWidth: 1,
                fillColor: {
                    colors: [{
                        opacity: 1
                    },
                    {
                        opacity: 0.4
                    }]
                }
            }
        }],
        options)



        $(".stat").each(function(i) {

            $(this).qtip({
                content: '<div class="stat"><p class="comp_this_workout"><span class="value">' + workout[this.id] + '</span>h for this hike</p> <p class="comp_my_activity"><span class="value">' + my_comps[this.id] + '</span>h average for all your hikes</p> <p class="comp_activity"><span class="value">' + all_comps[this.id] + '</span>h average for everyone's hikes < /p></div > ',

			show: 'mouseover ',
			hide: 'mouseout ',
			position: {
				type: 'absolute ',
				container: $('td.number '),
				corner: {
					tooltip: 'topLeft ',
					target: 'topRight '
				},
				adjust: {
					x:-204,
					y:-201
				}				
			},
			style: { 
				width: 288,
				padding: 8,
				background: '#f0f0f0 ',
				color: '#545454 ',
				textAlign: 'left ',
				border: {
				   width: 1,
				   radius: 8,
				   color: '#f0f0f0 '
				},
	   	}
	});
 });
});
});'