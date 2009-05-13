class Mailer < ActionMailer::Base
  def invitation(invitation, signup_url)
    subject    'Private Beta Invitation to ZED9 Social Fitness Analytics'
    recipients invitation.recipient_email
    from       current_user.email
	  bcc			['dropbox@01924470.zed9.highrisehq.com', 'batchbox+35165333@zed9.batchbook.com']
    body       :invitation => invitation, :signup_url => signup_url
    invitation.update_attribute(:sent_at, Time.now)
  end

end
