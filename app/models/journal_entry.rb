class JournalEntry < ActiveRecord::Base
	belongs_to  :user
	validates_presence_of :user_id
	validates_presence_of	:created_at

  def json_weights
		all_my_weights = {}
		aw = self.user.journal_entries.find(:all, :order => "entry_date DESC", :conditions => ["weight NOT null"])
		all_my_weights = (aw.map {|je| [(je.entry_date), je.weight]}).compact
    return all_my_weights
  end

  def manual_vo2?
    jevo2 = journal_entries.find(:last, :order => "entry_date ASC", :conditions => "vo2 NOT null")
    return jevo2.vo2 if jevo2
    # me = journal_entries.find(:all, :conditions => "vo2 NOT null")
    # if !me.nil?
    #   return true 
    # else 
    #   return false
    # end
  end

end
