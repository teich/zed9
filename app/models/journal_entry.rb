class JournalEntry < ActiveRecord::Base
	belongs_to  :user
	validates_presence_of :user_id
	validates_presence_of	:created_at
	validates_presence_of :weight
end
