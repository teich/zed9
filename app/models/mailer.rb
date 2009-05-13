class Mailer < ActionMailer::Base
  def invitation(invitation, signup_url)
    subject    'Invitation to Private Beta for ZED9 Social Fitness Analytics'
    recipients invitation.recipient_email
    from       invitation.sender.email
	  bcc			['batchbox+35165333@zed9.batchbook.com']
    body       :invitation => invitation, :signup_url => signup_url
    invitation.update_attribute(:sent_at, Time.now)
  end

end
