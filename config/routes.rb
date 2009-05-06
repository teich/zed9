ActionController::Routing::Routes.draw do |map|

  map.resource  :user_session
  map.resource  :dashboard, :only => [:show] 
  # I think I need to move this to a new controller called account.
  map.resource  :account, :controller => "users"
  map.resources :activities
  map.resources :invitations
 
  map.namespace :admin do |admin|
    admin.resources :users
    admin.resources :activities
  end
  
  map.resources :users, :only => [:show], :shallow => true do |user|
    user.resources :workouts do |workout|
#      workout.heart_rate_chart 'chart', :controller => 'charts', :action => 'workout_heart_rate' 
      workout.resources :taggings, :only => [:destroy, :create]
      workout.resource :comp, :only => [:show]
    end
  end
  
  map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => 'new' 
   
#  map.dashboard_chart '/dashboard/chart_data', :controller => 'charts', :action => 'dashboard_duration_data' 

  map.home ':page', :controller => 'home', :action => 'show', :page => /about|contact/
  map.root      :controller => "root", :action => "index"

end
