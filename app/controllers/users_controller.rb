class UsersController < ApplicationController
  skip_before_action :authenticate, only: [:create, :confirm]

  def create
    UserCreator.new(resource_params)
      .on(:succeeded) { |resource| render json: resource, status: 201 }
      .on(:failed) { |errors| render json: errors, status: 422 }
      .call
  end

  def confirm
    authorize User

    pundit_user.confirmed!

    head 200, message: 'user confirmed'
  end

  private
  def pundit_user
    user
  end

  def resource_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation).to_h
  end
end
