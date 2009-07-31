class JournalEntriesController < ApplicationController
	before_filter :require_user
	
	def index

		respond_to do |format|
			format.html
			format.xml {render :xml => @journal_entries.to_xml }
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
      redirect_to dashboard_path
    else
      @journal.destroy
      render :action => "new"
    end
      
    
  end
  
  # def update
  #   if @journal.update_attributes(params[:journal_entry])
  #     add_flash(:notice, 'Journal entry updated')
  #     redirect_to @journal_entries
  #   else
  #     render :action => "edit"
  #   end
  # end

end
