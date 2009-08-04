class JournalEntriesController < ApplicationController
	before_filter :require_user
	before_filter :find_journal_entry, :only => [:edit, :update, :destroy]
	
	def index

		@journal_entries = current_user.journal_entries.find(:all, :order => "entry_date DESC")
		@current_weight = current_user.weight(Time.now)
		@lowest_weight = current_user.journal_entries.find(:first, :order => "weight ASC", :conditions => ["weight NOT null"])
		@highest_weight = current_user.journal_entries.find(:first, :order => "weight DESC", :conditions => ["weight NOT null"])
		@current_vo2 = current_user.vo2(Time.now)
					    
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
  
end
