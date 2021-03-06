class JournalEntriesController < ApplicationController
	before_filter :require_user
	before_filter :find_journal_entry, :only => [:edit, :update, :destroy]
  before_filter :find_user, :only => [:index, :create, :new]
#  before_filter :require_mine, :only => [:index, :create]
	
	def index

    @gear = @user.gears.find(:all, :order => "created_at DESC")
    @gears = @user.gears.find(:all, :order => "purchase_date DESC")
    @journal_entries = @user.journal_entries.find(:all, :order => "entry_date DESC, created_at DESC")

    entries = @journal_entries + @gear
    @journal_feed = entries.sort { |a,b| b.created_at <=> a.created_at } .paginate :page => params[:page], :per_page => 10
      
		@current_weight = @user.weight(Time.now)
		@lowest_weight = @user.journal_entries.find(:first, :order => "weight ASC", :conditions => ["weight IS NOT NULL"])
		@highest_weight = @user.journal_entries.find(:first, :order => "weight DESC", :conditions => ["weight IS NOT NULL"])
		@current_vo2 = @user.vo2(Time.now)
				        
		respond_to do |format|
			format.html
			format.xml {render :xml => @journal_entries.to_xml }
      format.js {render :json => current_user.to_json(:except => [:single_access_token, :perishable_token, :password_salt, :persistence_token, :crypted_password], :methods => [:json_weights])} 
		end
		
	end

	def new
    @journal_entry = JournalEntry.new
	end

	def edit
	end

  def update
		if @journal_entry.update_attributes(params[:journal_entry])
			add_flash(:notice, 'Journal entry updated')
			redirect_to user_journal_entries_path(current_user)
		else
			render :action => "edit"
		end
  end
  
  def create
    @journal = @user.journal_entries.create(params[:journal_entry])
    if @journal.save
      add_flash(:notice, "Journal entry saved")
      redirect_to user_journal_entries_path
    else
      @journal.destroy
      render :action => "new"
    end
        
  end

  def destroy
    @journal_entry.destroy
    add_flash(:notice, "Journal entry deleted")
    redirect_to user_journal_entries_path(current_user)
  end

	def find_journal_entry
#    @journal_entry = current_user.journal_entries.find(params[:id])
    @journal_entry = JournalEntry.find(params[:id])
    if @journal_entry.user != current_user
      add_flash(:alert, "This page is private")
      redirect_to root_path
    end
	end    
  
  def find_user
		@user = User.find_by_login(params[:user_id])
		if @user.nil? || @user != current_user
    # if @user.nil? || !(!current_user.nil? && current_user.id == @user.id)
      add_flash(:alert, "This page is private")
      redirect_to root_path
    end
	end
	
  # def recent_entries
  #   JournalEntry.find(:all, :order => "entry_date DESC")
  # end
  
  # def require_mine
  #   if @journal_entry.user != current_user
  #     add_flash(:alert, "This page is private")
  #       redirect_to root_path
  #     end
  #   end
	
  
end
