require 'faker'

require File.expand_path(File.dirname(__FILE__) + "/blueprints")

Sham.name  { Faker::Name.name }
Sham.login { "aaaa" }
Sham.email { Faker::Internet.email }
Sham.title { Faker::Lorem.sentence }
Sham.body  { Faker::Lorem.paragraph }

Invitation.blueprint do
  recipient_email { Sham.email }
end

User.blueprint do
  invitation
  login
  email
  password { "blarg" }
  password_confirmation { password }
  sex { "male" }
  invitation_token { invitation.token }
end

Activity.blueprint do
	name
	icon_path { "/images/activities/weights.png" }
end

