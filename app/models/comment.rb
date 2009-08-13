class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  belongs_to :user


  def my_comment?
    @user == self.user
  end



end
