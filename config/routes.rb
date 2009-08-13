ActionController::Routing::Routes.draw do |map|

	map.resource  :user_session
	map.resource  :dashboard, :only => [:show] 
	map.resources :activities
	map.resources :invitations
  map.resources :password_resets
  
	map.namespace :admin do |admin|
		admin.resources :users
		admin.resources :activities
		admin.resources :achievements
	end

	map.resources :users, :shallow => true do |user|
    user.resources :journal_entries
    user.resources :gears
    # user.resources :gears do |gear|
    #   gear.resources :taggings, :shallow => false, :only => [:destroy, :create]
    # end
		user.resources :workouts do |workout|
		  workout.resources :comments
			workout.resources :overlaps, :shallow => false, :only => [:index, :destroy]
			workout.resources :taggings, :shallow => false, :only => [:destroy, :create]
    end
	end

	map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
	map.login '/login', :controller => 'user_sessions', :action => 'new' 
  # map.password_reset '/reset/:perishable_token', :controller => 'password_resets', :action => 'update'

	map.home ':page', :controller => 'home', :action => 'show', :page => /about|contact|devices|guide/
	map.root :controller => "root", :action => "index"
	map.connect '*path' , :controller => 'four_oh_fours'

end
