# app/controllers/api/v1/auth_controller.rb

module Api
    module V1
        class AuthController < ApplicationController
            include ActionController::Cookies
            def login
                user = User.find_by(email: params[:email])

                if user&.authenticate(params[:password])
                    token = JsonWebToken.encode(user_id: user.id)
                    cookies.signed[:jwt] = { value: token, httponly: true, secure: Rails.env.production? }
                    render json: { message: "Logged in successfully!" }, status: :ok
                else
                    render json: { message: "Invalid email or password" }, status: :unauthorized
                end
            end

            def logout
                cookies.delete(:jwt)
                render json: { message: "Logged out successfully!" }, status: :ok
            end
        end
    end
end