class Mailer < ActionMailer::Base
  def invitation(invitation, signup_url)
    subject    'Zed9 Invitation'
    recipients invitation.recipient_email
    from       'oren@teich.net'
    body       :invitation => invitation, :signup_url => signup_url
    invitation.update_attribute(:sent_at, Time.now)
  end

end
