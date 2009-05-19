PASSWORD = "blarg"

Given /^a user without any workouts$/ do
	activate_authlogic

	a = Activity.make()
	Activity.make(:name => "Uncategorized", :parent_id => a)
	user = User.make(:password => PASSWORD)
	
	visit "/login" 
	fill_in 'User name', :with => user.login
	fill_in 'Password', :with => PASSWORD
	click_button("Log in")
end

When /^I upload my first workout$/ do
	click_link "Workouts"
	click_link "Add"
	click_link "GPS"
	fill_in "workout_name", :with => "GPX Tester"
	#save_and_open_page
	attaches_file "workout_devices_attributes_0_source", Rails.root.join("spec", "fixtures", "sample.gpx") 
	click_button "Save"
end

Then /^I should get the "([^\"]*)" achievement$/ do |arg1|
  pending
end

Given /^a user with one achievement$/ do
  pending
end

When /^I visit my achievements page$/ do
  pending
end

Then /^I should see my "([^\"]*)" achievement$/ do |arg1|
  pending
end
