class User < ActiveRecord::Base
	acts_as_authentic do |c|
		c.validates_length_of_login_field_options = {:within => 2..20}
	end

	# TODO: for testing, I'm removing this till I figure out how to bypass
	validates_presence_of :invitation_id, :message => 'is required'
	validates_uniqueness_of :invitation_id
	validates_inclusion_of :sex, :in => %w( male female ), :on => :create, :message => "must be male/female"
	validates_format_of :login, :with => /^\w+$/i, :message => "can only contain letters and numbers."

	belongs_to :invitation  
	has_many :accomplishments
	has_many :achievements, :through => :accomplishments, :uniq => true, :dependent => :destroy
	has_many :hr_zones, :dependent => :destroy
	has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
	has_many :workouts, :dependent => :destroy
  # has_many :workouts, :dependent => :destroy, :order => 'start_time ASC'

	before_create :set_invitation_limit

	attr_accessible :login, :email, :name, :password, :password_confirmation, :invitation_token, :birthdate, :sex, :height, :time_zone, :shared, :displayname, :bio

  def start_time
    start_time_edited || start_time_file
  end

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
  
  def json_workouts_per_week
    # bar = []
    # activities = top_activities.map {|a| a[1] }
    # for a in activities
    foo = []
    11.downto(0) {|i| foo << [11- i, workouts_per_week(i)] }
    foo
    #   bar << foo
    #   
    # end
    # 
    # stuff = 3 - bar.length
    # (0..stuff).each {|i| bar << [[0,0]]}
    # 
    # snarf = []
    # 11.downto(0) {|i| snarf << [11 - i, workouts_per_week(i, nil, activities)]}
    # bar[3] = snarf
    # return bar
  end
  
  def top_activities
    something = {}
    tops = []
    activities = workouts.map { |w| [w.activity.name, w.activity.id]}
    activities.each do |a| 
      if something[a].nil?
        something[a] = 1
      else
        something[a] += 1
      end
    end

    sorted = something.sort {|a,b| a[1]<=>b[1]}
    sorted.reverse!
    
    if sorted.length < 3
      tops = sorted
    else
      (0..2).each do |i|
        tops << sorted[i][0]
      end
    end
    tops
  end
  
  def json_hours_per_week
    foo = []
    11.downto(0) {|i| foo << [(11 - i) + 0.45, hours_per_week(i)] }
    return foo
  end
  
  def json_weeks_labels
    foo = []
    11.downto(0) { |i| foo << [(11 - i) + 0.45, (i+1).weeks.ago.strftime("%m/%d").gsub(/0?(\d)\/0?(\d{1,2})/,'\1/\2')] }
    foo
  end
  
  def workouts_per_week(weeks_ago, activity = nil, exclude = nil)
    if !exclude.nil?
      workouts.count(:conditions => ['start_time < ? AND start_time > ? AND activity_id NOT IN (?)', weeks_ago.weeks.ago, (weeks_ago + 1).weeks.ago, exclude])
    elsif activity.nil?
      workouts.count(:conditions => ['start_time < ? AND start_time > ?', weeks_ago.weeks.ago, (weeks_ago + 1).weeks.ago])
    else
      workouts.count(:conditions => ['start_time < ? AND start_time > ? AND activity_id = ?', weeks_ago.weeks.ago, (weeks_ago + 1).weeks.ago, activity])
    end
  end
  
  def hours_per_week(weeks_ago)
    workouts.sum('duration', :conditions =>  ['start_time < ? AND start_time > ?', weeks_ago.weeks.ago, (weeks_ago + 1).weeks.ago]) / 3600
  end
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Mailer.deliver_password_reset_instructions(self)  
  end
  
	private

	# How many invitations does a user get?
	def set_invitation_limit
		self.invitation_limit = 10
	end
	



end
