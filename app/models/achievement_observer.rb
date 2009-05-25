class AchievementObserver < ActiveRecord::Observer
  
  observe :workout, :invitation
  
  def after_create
  	achievements = Achievement.find(:all, :conditions => ['controller = ? AND action = ?', params[:controller], params[:action]])
  	achievements.each do |a|
  		if eval a.logic and !current_user.awarded?(a)
  			current_user.award(a)
  			add_flash(:achievement, "You've earned a new achievement: #{a.name}")
  		end
  	end
  end
end