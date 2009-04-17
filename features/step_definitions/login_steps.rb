Given /^I am logged in as user "([^\"]*)"$/ do |login|
  @current_user = User.create!(
    :login => login,
    :password => "generic",
    :password_confirmation => "generic",
    :email => "#{login}@test.com",
    :sex => "male"
  )
  
  visit "/login" 
  fill_in('Login', :with => @current_user.login )
  fill_in('Password', :with => "generic")
  click_button("Login")
end

Given /^a registered user "([^\"]*)"$/ do |login|
  @current_user = User.create!(
    :login => login,
    :password => "generic",
    :password_confirmation => "generic",
    :email => "#{login}@test.com",
    :sex => "male"
  )
end

When /^the user "([^\"]*)" logs in$/ do |user|
  visit "/login" 
  fill_in('Login', :with => @current_user.login )
  fill_in('Password', :with => "generic")
  click_button("Login")
end



