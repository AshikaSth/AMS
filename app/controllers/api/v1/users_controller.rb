class Api::V1::UsersController < ApplicationController
  # before_action :authorize_request, only: [:index, :show ]  
  skip_before_action :authorize_request, only: [:index, :show, :create, :update, :destroy]

  # GET api/v1/users
  def index
    @users = User.all
    render json: @users, each_serializer: UserSerializer, status: :ok
  end

  # GET api/v1/users/[:id]
  def show
    @user = User.find(params[:id])
    render json: @user, serializer: UserSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  # POST api/v1/users
  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, serializer: UserSerializer, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH api/v1/users/[:id]
  def update
      @user = User.find(params[:id])

    if @user.update(user_params)
      render json: @user, serializer: UserSerializer, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE api/v1/users/[:id]
  def destroy
    begin
      @user = User.find(params[:id])
      @user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :not_found
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :password, :password_confirmation,
      :phone_number, :gender, :address, :dob
    )
  end
end