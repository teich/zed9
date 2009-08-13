class JournalEntry < ActiveRecord::Base
	belongs_to  :user
	validates_presence_of :user_id
	validates_presence_of	:created_at

  # def recent_entries
  #   self.find_all_by_created_at()
  # end

  def sort_timestamp
    self.entry_date
  end 


end
