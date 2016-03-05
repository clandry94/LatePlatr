class RecurringdinnerplatesController < ApplicationController
  def update
    @recur_dinner_plate = RecurringDinnerPlate.find_by_user_id(current_user.id)
    if @recur_dinner_plate.update_attributes(recur_dinner_params)
      flash[:sucess] = 'Your recurring dinner options have been saved.'
      redirect_to manage_plates_path
    else
      flash[:danger] = 'An error has occurred, please try again.'
      redirect_to manage_plates_path
    end
  end

  private

  def recur_dinner_params
    params.permit(:user_id, :monday, :tuesday, :wednesday, :thursday, :friday)
  end
end
