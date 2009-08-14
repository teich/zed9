class Mailer < ActionMailer::Base
  def invitation(invitation, signup_url)
    subject    'Invitation to Private Beta for ZED9 Social Fitness Analytics'
    recipients invitation.recipient_email
    from       invitation.sender.email
    body       :invitation => invitation, :signup_url => signup_url
    invitation.update_attribute(:sent_at, Time.now)
  end

  def password_reset_instructions(user)  
    subject       "Request to reset ZED9 password"  
    from          "ZED9 <support@zednine.com>"  
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)  
  end
  
  def comment_own(workout, comment)
    subject       "Someone commented on one of your workouts"
    from          "ZED9 <support@zednine.com>"
    recipients   workout.user.email
    sent_on       Time.now
    body          :workout => workout, :comment => comment
  end  
  
  def comment_following(workout, user, comment)
    subject       "A comment has been posted on a workout you are following"
    from          "ZED9 <support@zednine.com>"
    recipients   user.email
    sent_on       Time.now
    body          :workout => workout, :user => user, :comment => comment
  end
end
