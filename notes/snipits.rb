## Some useful snipits for reference

# Find all workouts with the same activity.  Globally, across all users
Activity.find(@workout.activity.id).workouts

# Find all workouts of a specific activity for just current user
current_user.workouts.find(:all, :conditions => ['activity_id == ?', @workout.activity.id])

# Find all workouts matching a list of tags, across all users:
Workout.find_tagged_with(tag_list, :match_all => true)

# Find all workouts matching tag for just current user
current_user.workouts.find_tagged_with(workout.tag_list, :match_all => true)
