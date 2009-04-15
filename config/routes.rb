ActionController::Routing::Routes.draw do |map|

  map.resources :invitations

  map.resource  :account, :controller => "users"
  map.resources :workouts do |workout|
      workout.resources :trackpoints
      workout.resource  :chart, :only => [:show]
  end
  
  map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => 'new' 
   
  map.resource  :user_session
  map.root      :controller => "root", :action => "index"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
#  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
end
