class User < ActiveRecord::Base
  acts_as_authentic
  
  # for testing, I'm removing this till I figure out how to bypass
  #validates_presence_of :invitation_id, :message => 'is required'
  #validates_uniqueness_of :invitation_id

  validates_inclusion_of :sex, :in => %w( male female ), :on => :create, :message => "must be male/female"
  
  has_many :workouts
  has_many :hr_zones
  
  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation
  
  before_create :set_invitation_limit
  
  attr_accessible :login, :email, :name, :password, :password_confirmation, :invitation_token, :birthdate, :sex, :height
    
  def invitation_token
    invitation.token if invitation
  end
  
  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end
  
  def age
    (Date.today - birthdate).to_i / 365
  end
  
  private
  
  def set_invitation_limit
    self.invitation_limit = 5
  end
end
