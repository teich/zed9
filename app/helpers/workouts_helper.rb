module WorkoutsHelper

  def is_garmin?
    @controller.send(:is_garmin?)
  end
  
end