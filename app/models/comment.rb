class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  
  
  def notify!(commentable, current_user)
    #send the owner of the item the comment
    Mailer.deliver_comment_own(commentable)
    logger.debug "Just send the owner the mail\n\n\n"
    
    #send all the followers comments too
    all = commentable.comments.map {|c| c.user}.uniq
    for person in all 
      logger.debug "In the people mailer!\n\n\n\n"
      if person != current_user && !person.nil?
        logger.debug "Going to try and mail #{person}"
        Mailer.deliver_comment_following(person, commentable) 
      end
    end  
  end
    
end
