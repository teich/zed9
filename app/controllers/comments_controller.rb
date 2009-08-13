class CommentsController < ApplicationController
  def index
    @commentable = find_commentable
    logger.debug "COMMENTABLE IS #{@commentable}"
    @comments = @commentable.comments
  end

  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(params[:comment])
    @comment.user = current_user
    if @comment.save
      flash[:notice] = "Successfully created comment."
      @comment.notify!(@commentable, current_user)
      redirect_to workout_path(@commentable)
    else
      render :action => 'new'
    end
  end

  private

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end
  
end
