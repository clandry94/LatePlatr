include UsersHelper

class UsersController < ApplicationController
  before_action :logged_in, only: [:index, :edit, :update, :show, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  # Set up pages using the paginate gem
  # TODO: Change number of users per page
  def index
    @users = User.paginate(page: params[:page])
  end

  # Creates a new user
  def new
    @user = User.new
  end

  # Main method behind the creation of plates of users
  # FIXME: Fix recurring late plate modification, currently doesn't work and
  # updates are not saved
  #
  # OPTIMIZE: Use rails associations for creation instead of by hand
  def manage_plates
    @breakfast_plate = BreakfastPlate.new
    @dinner_plate = DinnerPlate.new
    @recur_breakfast_plate = RecurringBreakfastPlate.new
    @recur_dinner_plate = RecurringDinnerPlate.new

    @breakfast_plates = BreakfastPlate.where(user_id: current_user.id)
    @dinner_plates = DinnerPlate.where(user_id: current_user.id)
    @recur_breakfast_plates = RecurringBreakfastPlate.where(user_id: current_user.id)
    @recur_dinner_plates = RecurringDinnerPlate.where(user_id: current_user.id)
  end

  # Creates a new user and handles validation issues
  # OPTIMIZE: use build in validations instead of by hand
  def create
    @user = User.new(user_params)

    # Ensure the email addres is not a duplicate
    # If blank? returns true, then there is no user in the
    # database that has the same email as the user being created
    if User.where(email_address: @user.email_address).blank?
      if @user.save
        init_recur_plates @user # Setup recurring plate entry
        log_in @user  # log in user right after sign up
        flash[:success] = 'Welcome to the LatePlate-o-Tron 3000!'
        redirect_to user_url(@user) # handle successful signup
      else
        render 'new'
      end
    # Make the user retry if the email is already being used
    elsif !User.where(email_address: @user.email_address).blank?
      flash[:danger] = 'A user with this email address already exists!'
      redirect_to root_url
    end
  end

  # Show user information on profile page
  def show
    @user = User.find(params[:id])
    @breakfast_plates = BreakfastPlate.where(user_id: current_user.id)
    @dinner_plates = DinnerPlate.where(user_id: current_user.id)
    @recur_breakfast_plates = RecurringBreakfastPlate.where(user_id: current_user.id)
    @recur_dinner_plates = RecurringDinnerPlate.where(user_id: current_user.id)
    # byebug
  end

  def edit
    @user = User.find(params[:id])
  end

  # Update attributes of a user
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  # Destroy a user
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address,
                                 :phone_number, :password, :password_confirmation)
  end

  def logged_in
    unless logged_in?
      flash[:danger] = 'You must be logged in to do that'
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
