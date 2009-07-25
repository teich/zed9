class PasswordResetsController < ApplicationController  
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  
  before_filter :require_no_user 
  
  def new  
    render  
  end  
  
  def create  
    @user = User.find_by_email(params[:user][:email])  
    if @user
      @user.deliver_password_reset_instructions!  
      flash[:info] = "Please check your email for a link to reset your password."  
      redirect_to root_url  
    else  
      flash[:alert] = "We were unable to find an account with that email address."  
      render :action => :new  
    end  
  end  

  def edit  
    render  
  end  

  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save  
      flash[:notice] = "Password successfully updated"  
      redirect_to root_path  
    else  
      render :action => :edit  
    end  
  end  

  private  
    def load_user_using_perishable_token  
      @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:alert] = "We're sorry, but we could not locate your account. Please try copying and pasting the URL from your password reset email into your browser or restarting the reset password process."  
      redirect_to root_url  
    end  
  end
  
end