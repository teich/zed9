class GearsController < ApplicationController
	before_filter :require_user
	before_filter :find_gear, :only => [:edit, :update, :destroy]
  before_filter :find_user, :only => [:index, :create, :new]
	
	def index
	end
	
	def new
    # @gear = current_user.Gear.build
    @gear = Gear.new
	end

	def edit
	end

  def update
		if @gear.update_attributes(params[:gear])
			add_flash(:notice, 'Gear info updated')
			redirect_to user_journal_entries_path(current_user)
		else
			render :action => "edit"
		end
  end
  
  def create
    @gear = @user.gears.create(params[:gear])
    if @gear.save
      add_flash(:notice, "Gear info added")
      redirect_to user_journal_entries_path
    else
      @gear.destroy
      render :action => "new"
    end
        
  end

  def destroy
    @gear.destroy
    add_flash(:notice, "Gear deleted")
    redirect_to user_journal_entries_path(current_user)
  end

	def find_gear
    @gear = Gear.find(params[:id])
    if @gear.user != current_user
      add_flash(:alert, "This page is private")
      redirect_to root_path
    end
	end    
  
  def find_user
		@user = User.find_by_login(params[:user_id])
		if @user.nil? || @user != current_user
      add_flash(:alert, "This page is private")
      redirect_to root_path
    end
	end
	
  
end
