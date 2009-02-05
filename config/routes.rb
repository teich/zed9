ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.


  # Restful-authentication
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  map.signup '/signup', :controller => 'user/profiles', :action => 'new'
  map.beta_signup '/signup/:invitation_token', :controller => 'user/profiles', :action => 'new'
  
  map.activate '/activate/:activation_code', :controller => 'user/activations', :action => 'activate', :activation_code => nil

  map.forgot_password '/forgot_password', :controller => 'user/passwords', :action => 'new'  
	map.reset_password '/reset_password/:id', :controller => 'user/passwords', :action => 'edit', :id => nil  
	map.resend_activation '/resend_activation', :controller => 'user/activations', :action => 'new'
  
  map.namespace :user do |user|
		user.resources :activations
		user.resources :invitations
		user.resources :openid_accounts 
		user.resources :passwords
    user.resources :profiles do |profiles|
			profiles.resources :password_settings
		end
  end
  
  map.resources :users
  map.resource  :session
  map.resources :activities, :has_many => [:trackpoints]   
  map.resources :members
	 
  map.load_chart '/load_chart', :controller => 'activities', :action => 'load_chart'
 
  map.root :controller => "root", :action => "index"
 
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
