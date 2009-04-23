ActionController::Routing::Routes.draw do |map|

  map.resources :invitations

  map.resource  :account, :controller => "users", :only => [:show, :update, :destroy] 
  map.resources :workouts do |workout|
      #workout.resources :trackpoints
      workout.resource  :chart, :only => [:show]
      workout.resources :taggings, :only => [:destroy, :create]
  end
  
  map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => 'new' 
   
  map.resource  :dashboard, :only => [:show] 
  map.dashboard_chart '/dashboard/chart_data', :controller => 'charts', :action => 'dashboard_duration_data' 

  map.resource  :user_session
  map.root      :controller => "root", :action => "index"

end
