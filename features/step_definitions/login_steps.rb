Given /^a registered user "(.*)"$/ do |login|
  @current_user = User.create!(
    :login => login,
    :password => "generic",
    :password_confirmation => "generic",
    :email => "#{login}@test.com",
    :sex => "male"
  )
end

When /^the user "([^\"]*)" logs in$/ do |arg1|
  visit "/login" 
  fill_in('Login', :with => @current_user.login )
  fill_in('Password', :with => "generic")
  click_button("Login")
end



