# Feature: Browse workouts
# 	In order to track my exercising
# 	As a user
# 	I want see and view workouts that I upload
# 	
# 	Scenario: View list of workouts
# 		Given I am logged in as user "test"
# 		And I have a workout titled "Kempo"
# 		When I go to the list of workouts
# 		Then I should see "Kempo"
# 		
# 	Scenario: title
# 		Given I am logged in as user "test"
# 	  	And I have a workout titled "Fun"
# 		And I am viewing the workout page for the "Fun" workout
# 		When I follow "Edit"
# 		And I fill in "Tag list" with "testTag"
# 		And I press "Save"
# 	  	Then I should see "testTag"
# 		And I should have 1 tags
# 	
# 	
# 	