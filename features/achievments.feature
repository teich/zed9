Feature: Achievements
	So that I can incent users on the site
	As a registered user
	I want to get achievements when I do certain activities
	
	Scenario: Uploading first workout gives user an achievement
		Given a user without any workouts
		When I upload my first workout
		Then I should get the "first workout" achievement
		
	Scenario: Viewing achievements earned
		Given a user with one achievement
		When I visit my achievements page
		Then I should see my "first workout" achievement
	
