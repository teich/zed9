class Gear < ActiveRecord::Base
	belongs_to  :user
  belongs_to :journal_entry
	validates_presence_of :user_id
	validates_presence_of	:name
end
