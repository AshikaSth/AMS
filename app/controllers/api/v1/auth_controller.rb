# app/controllers/api/v1/auth_controller.rb

module Api
    module V1
        class AuthController < ApplicationController
            include ActionController::Cookies
            before_action :authorize_request, only: [ :profile, :logout ]
            def login
                user = User.find_by(email: params[:email])

                if user&.authenticate(params[:password])
                    service = AuthenticationService.new(user)

                    access_token = service.generate_access_token
                    refresh_token = service.generate_refresh_token

                    user.refresh_tokens.create!(
                        token: Digest::SHA256.hexdigest(refresh_token),
                        expires_at: 7.days.from_now
                    )

                    cookies.signed[:access_token] = { value: access_token, httponly: true, secure: Rails.env.production?, expires: 15.minutes.from_now }
                    cookies.signed[:refresh_token] = { value: refresh_token, httponly: true, secure: Rails.env.production?, expires: 7.days.from_now }
                    render json: { message: "Logged in successfully!", user: user  }, status: :ok
                else
                    render json: { message: "Invalid email or password" }, status: :unauthorized
                end
            end

            def logout
                if cookies.signed[:refresh_token]
                    token = Digest::SHA256.hexdigest(cookies.signed[:refresh_token])
                    current_user.refresh_tokens.where(token: token).update_all(revoked: true)
                end

                cookies.delete(:access_token)
                cookies.delete(:refresh_token)

            end

            def profile 
            render json: current_user, serializer: UserSerializer
            end
        end
    end
end