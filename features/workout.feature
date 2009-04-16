Feature: Browse workouts
	In order to track my excercising
	As a user
	I want see and view workouts that I upload
	
	Scenario: View list of workouts
		Given a registered user "test"
		When the user "test" logs in
		And I go to the workout page
		Then I should see "Listing workouts"
		
	Scenario: Workout includes HR