class Api::V1::UsersController < ApplicationController

  # GET api/v1/users
  def index
      @users=policy_scope(User)
      render json: @users, each_serializer: UserSerializer, status: :ok
  end

  # GET api/v1/users/[:id]
  def show
    @user = User.find(params[:id])
    render json: @user, serializer: UserSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def unassigned_artists
    authorize User, :unassigned_artists?
    @users = User.where(role: 'artist').left_outer_joins(:artist).where(artists: { id: nil })
    render json: @users, each_serializer: UserSerializer, status: :ok
  end

  # POST api/v1/users
  def create
    begin
      @user = User.new(user_params)
      authorize @user
      if @user.save
        render json: @user, serializer: UserSerializer, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  # PATCH api/v1/users/[:id]
  def update
    begin
      @user = User.find(params[:id])
      authorize @user

      if @user.update(user_params)
        render json: @user, serializer: UserSerializer, status: :ok
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  # DELETE api/v1/users/[:id]
  def destroy
    begin
      @user = User.find(params[:id])
      authorize @user

      @user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :not_found
      rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :password, :password_confirmation,
      :phone_number, :gender, :address, :dob, :role
    )
  end
end