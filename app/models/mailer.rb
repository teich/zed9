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
  
end
