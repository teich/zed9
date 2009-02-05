require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
	include Authentication::UserAbstraction
  include Authentication::ByCookieToken

	set_inheritance_column :user_type
	validates_presence_of  :user_type
	
  has_many :activities
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :invitation_token



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  	def self.member_list(page)
  		paginate :all,
  						 :per_page => 50, :page => page,
          		 :conditions => ['enabled = ? and activated_at IS NOT NULL', true],
          		 :order => 'login'
  	end

  	def self.administrative_member_list(page)
  		paginate :all,
  						 :per_page => 50, :page => page,
          		 :order => 'login'
  	end

  	def to_xml(options = {})
  		#Add attributes accessible by xml
    	#Ex. default_only = [:id, :login, :name]
  		default_only = []
    	options[:only] = (options[:only] || []) + default_only
    	super(options)
    end

end
