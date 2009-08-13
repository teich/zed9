class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  
  
  def notify!(commentable, current_user)
    #send the owner of the item the comment
    if current_user != commentable.user
      Mailer.deliver_comment_own(commentable)
    end
    
    #send all the followers comments too
    all = commentable.comments.map {|c| c.user}.uniq
    for person in all 
      if person != current_user
        Mailer.deliver_comment_following(person, commentable) 
      end
    end  
  end
    
end
