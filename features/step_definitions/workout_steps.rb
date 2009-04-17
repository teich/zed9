Given /^I have a workout titled "([^\"]*)"$/ do |name|
  @workout = @current_user.workouts.create!(
    :name => name
  )
end

Given /^I am viewing the workout page for the "([^\"]*)" workout$/ do |name|
  workout = Workout.find_by_name(name)
  
  # TODO WHY IS THIS THROWING A DIVIDE BY ZERO ERROR?
  #visit workout_path(workout)
end
