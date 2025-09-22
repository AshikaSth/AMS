
class ApplicationController < ActionController::API
  include Pundit::Authorization
  include ActionController::Cookies

  before_action :authorize_request, except: []
  attr_reader :current_user

  private

  def authorize_request
    token = cookies.signed[:access_token]
    payload = JsonWebToken.decode(token)

    if payload && payload["type"] == "access"
      @current_user = User.find_by(id: payload["user_id"])
    end

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
