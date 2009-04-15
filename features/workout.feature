Feature: Browse workouts
	In order to look at my workouts
	As a user
	I want to see overview and details of my uploaded workouts
	
	Scenario: View list of workouts
		Given a registered user "test"
		When the user "test" logs in
		And I go to the workout page
		Then I should see "Listing workouts"