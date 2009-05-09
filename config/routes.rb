ActionController::Routing::Routes.draw do |map|

	map.resource  :user_session
	map.resource  :dashboard, :only => [:show] 
	map.resource  :account, :controller => "users"
	map.resources :activities
	map.resources :invitations

	map.namespace :admin do |admin|
		admin.resources :users
		admin.resources :activities
	end

	map.resources :users, :only => [:show], :shallow => true do |user|
		user.resources :workouts do |workout|
			workout.resources :overlaps, :shallow => false, :only => [:index, :destroy]
			workout.resources :taggings, :shallow => false, :only => [:destroy, :create]
		end
	end

	map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
	map.login '/login', :controller => 'user_sessions', :action => 'new' 


	map.home ':page', :controller => 'home', :action => 'show', :page => /about|contact|devices/
	map.root :controller => "root", :action => "index"

end
