ActionController::Routing::Routes.draw do |map|

  map.resource  :user_session
  map.resource  :dashboard, :only => [:show] 
  map.resource  :account, :controller => "users"
  map.resources :activities, :only =>[:index]

  map.resources :invitations
#  map.resources :workouts, :path_prefix => ':user_name'  do |workout|
  map.resources :workouts do |workout|

      workout.heart_rate_chart 'chart', :controller => 'charts', :action => 'workout_heart_rate' 
      workout.resources :taggings, :only => [:destroy, :create]
  end
  
  map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => 'new' 
   
  map.dashboard_chart '/dashboard/chart_data', :controller => 'charts', :action => 'dashboard_duration_data' 

  map.root      :controller => "root", :action => "index"

end
