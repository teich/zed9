ach = Achievement.find_by_name("Novice")
if !ach
  Achievement.create( :name => "Novice", 
                      :description => "Uploaded first workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "current_user.workouts.size > 0"
                    )
                         
end


ach = Achievement.find_by_name("Acolyte")
if !ach
  Achievement.create( :name => "Acolyte", 
                      :description => "Uploaded 5th workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "current_user.workouts.size > 4"
                    )
                         
end

ach = Achievement.find_by_name("Apprentice")
if !ach
  Achievement.create( :name => "Apprentice", 
                      :description => "Uploaded 10th workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "current_user.workouts.size > 9"
                    )
end

ach = Achievement.find_by_name("Fit Freak")
if !ach
  Achievement.create( :name => "Fit Freak", 
                      :description => "Uploaded 50th workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "current_user.workouts.size > 49"
                    )
end

ach = Achievement.find_by_name("Fit Master")
if !ach
  Achievement.create( :name => "Fit Master", 
                      :description => "Uploaded 100th workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "current_user.workouts.size > 99"
                    )
end

############################
# INVITATIONS

ach = Achievement.find_by_name("Networker")
if !ach
  Achievement.create( :name => "Networker", 
                      :description => "Invited 5 friends",
                      :controller => "invitations",
                      :action => "create",
                      :logic => "current_user.sent_invitations.size > 4"
                    )
end


# duration achievements
ach = Achievement.find_by_name("Good Start")
if !ach
  Achievement.create( :name => "Good Start", 
                      :description => "Over 10 hours logged",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "current_user.workouts.sum('duration') > 36000"
                    )
end

ach = Achievement.find_by_name("Stick With It")
if !ach
  Achievement.create( :name => "Stick With It", 
                      :description => "Over 100 hours logged",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "current_user.workouts.sum('duration') > 360000"
                    )
end

ach = Achievement.find_by_name("Perserverence")
if !ach
  Achievement.create( :name => "Perserverence", 
                      :description => "Over 1000 hours logged",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "current_user.workouts.sum('duration') > 3600000"
                    )
end

# Climbing in a workout
ach = Achievement.find_by_name("Eagle Mountain")
if !ach
  Achievement.create( :name => "Eagle Mountain", 
                      :description => "Climbed the height of Minnesota's Eagle Mountain in one workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "!@workout.elevation.nil? and @workout.elevation > 701"
                    )
end

ach = Achievement.find_by_name("Mount Sunflower")
if !ach
  Achievement.create( :name => "Mount Sunflower", 
                      :description => "Climbed the height of Kansas' Mount Sunflower in one workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "!@workout.elevation.nil? and @workout.elevation > 1231"
                    )
end

ach = Achievement.find_by_name("Guadalupe Peak")
if !ach
  Achievement.create( :name => "Guadalupe Peak", 
                      :description => "Climbed the height of Texas' Guadalupe Peak in one workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "!@workout.elevation.nil? and @workout.elevation > 2667"
                    )
end

ach = Achievement.find_by_name("Mount Whitney")
if !ach
  Achievement.create( :name => "Mount Whitney", 
                      :description => "Climbed the height of California's Mount Whitney in one workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "!@workout.elevation.nil? and @workout.elevation > 4418"
                    )
end

ach = Achievement.find_by_name("Mount Everest")
if !ach
  Achievement.create( :name => "Mount Everest", 
                      :description => "Climbed the height of Nepal's Mount Everest in one workout",
                      :controller => "workouts",
                      :action => "create",
                      :logic => "!@workout.elevation.nil? and @workout.elevation > 8848"
                    )
end