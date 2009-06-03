class User < ActiveRecord::Base
	acts_as_authentic do |c|
		c.validates_length_of_login_field_options = {:within => 2..20}
	end

	# TODO: for testing, I'm removing this till I figure out how to bypass
	validates_presence_of :invitation_id, :message => 'is required'
	validates_uniqueness_of :invitation_id
	validates_inclusion_of :sex, :in => %w( male female ), :on => :create, :message => "must be male/female"

	belongs_to :invitation  
	has_many :accomplishments
	has_many :achievements, :through => :accomplishments, :uniq => true, :dependent => :destroy
	has_many :hr_zones, :dependent => :destroy
	has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
	has_many :workouts, :dependent => :destroy

	before_create :set_invitation_limit

	attr_accessible :login, :email, :name, :password, :password_confirmation, :invitation_token, :birthdate, :sex, :height, :time_zone, :shared, :displayname

	def invitation_token
		invitation.token if invitation
	end

	def invitation_token=(token)
		self.invitation = Invitation.find_by_token(token)
	end

	def age
		return nil if birthdate.nil?
		(Date.today - birthdate).to_i / 365
	end

	def admin_user?
		admin
	end

	def to_param
		"#{login.gsub(/[^a-z0-9]+/i, '-')}"
	end

	def display_name
		if displayname.nil? || displayname == ""
			return login
		else 
			return displayname
		end
	end
	
	def award(achievement)
     achievements << achievement
  end
   
	def awarded?(achievement)
	  achievements.count(:conditions => { :id => achievement.id }) > 0
  end
	
	def points
    (accomplishments.size * 10) + self.workouts.size
  end
  
  def workouts_per_week(weeks_ago)
    workouts.count(:conditions => ['start_time < ? AND start_time > ?', weeks_ago.weeks.ago, (weeks_ago + 1).weeks.ago])
  end
  
  def hours_per_week(weeks_ago)
    workouts.sum('duration', :conditions =>  ['start_time < ? AND start_time > ?', weeks_ago.weeks.ago, (weeks_ago + 1).weeks.ago])
  end
	private

	# How many invitations does a user get?
	def set_invitation_limit
		self.invitation_limit = 10
	end
	



end
