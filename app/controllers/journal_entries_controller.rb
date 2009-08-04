class JournalEntriesController < ApplicationController
	before_filter :require_user
	before_filter :find_journal_entry, :only => [:edit, :update, :destroy]
	before_filter :find_user_and_require_public
	
	def index

		@journal_entries = @user.journal_entries.find(:all, :order => "entry_date DESC")
		@current_weight = @user.weight(Time.now)
		@lowest_weight = @user.journal_entries.find(:first, :order => "weight ASC", :conditions => ["weight NOT null"])
		@highest_weight = @user.journal_entries.find(:first, :order => "weight DESC", :conditions => ["weight NOT null"])
		@current_vo2 = @user.vo2(Time.now)
				    
		respond_to do |format|
			format.html
			format.xml {render :xml => @journal_entries.to_xml }
      format.js {render :js => current_user.json_weights.to_json}
		end

      
	end

	def show
  	
		respond_to do |format|
			format.html
			format.xml {render :xml => @journal_entry.to_xml }
			format.js {render :js => @journal_entry.to_json(:methods => :weight, :include => :user)}
		end
	end

	def new
    @journal_entry = JournalEntry.new
    # @journal_entry = current_user.journal_entry.build
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
    @journal = current_user.journal_entries.create(params[:journal_entry])
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
    redirect_to(user_journal_entries_path(current_user))
  end

	def find_journal_entry
		@journal_entry = current_user.journal_entries.find(params[:id])
	end    
  
  def find_user_and_require_public
		@user = User.find_by_login(params[:user_id])
    if @user.nil? || !(!current_user.nil? && current_user.id == @user.id)
      add_flash(:alert, "This page is private")
      redirect_to root_path
    end
	end
	
  
end
