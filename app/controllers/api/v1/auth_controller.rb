# app/controllers/api/v1/auth_controller.rb

module Api
    module V1
        class AuthController < ApplicationController
            include ActionController::Cookies
            before_action :authorize_request, only: [ :profile, :logout, :refresh, :update_profile]
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

                    cookies.signed[:access_token] = { value: access_token, httponly: true, secure: true, expires: 7.days.from_now, same_site: :none  }
                    cookies.signed[:refresh_token] = { value: refresh_token, httponly: true, secure: true, expires: 7.days.from_now, same_site: :none }
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


            def register
                user= User.new(user_params)
                user.role = 'artist'
                if user.save
                    UserMailer.verify_email(user).deliver_later
                    render json: user, serializer: UserSerializer, status: :created
                else
                    render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
                end
            end

            def refresh
                refresh_token_value = cookies.signed[:refresh_token]

                decoded_token = JsonWebToken.decode(refresh_token_value)

                if decoded_token && decoded_token['type'] == 'refresh'
                    user = User.find(decoded_token['user_id'])
                    refresh_token = user.refresh_tokens.find_by(
                    token: Digest::SHA256.hexdigest(refresh_token_value)
                    )

                    if refresh_token && !refresh_token.revoked && refresh_token.expires_at > Time.now
                    new_access_token = AuthenticationService.new(user).generate_access_token
                    new_refresh_token = AuthenticationService.new(user).generate_refresh_token

                    refresh_token.update!(revoked: true)
                    user.refresh_tokens.create!(
                        token: Digest::SHA256.hexdigest(new_refresh_token),
                        expires_at: 7.days.from_now
                    )

                    cookies.signed[:access_token] = { value: new_access_token, httponly: true, secure: Rails.env.production?, expires: 15.minutes.from_now }
                    cookies.signed[:refresh_token] = { value: new_refresh_token, httponly: true, secure: Rails.env.production?, expires: 7.days.from_now }

                    render json: { message: "Tokens refreshed successfully!" }, status: :ok
                    else
                    render json: { error: "Invalid refresh token" }, status: :unauthorized
                    end
                else
                    render json: { error: "Invalid refresh token" }, status: :unauthorized
                end
            end

    def profile
        render json: current_user, serializer: UserSerializer, from_profile: true
    end

    def update_profile
        ActiveRecord::Base.transaction do
            user_params = profile_params.except(:artist)
            if user_params.present?
                unless current_user.update(user_params)
                    render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
                    return
                end
            end

            if current_user.artist? && profile_params[:artist].present?
                @artist = current_user.artist || current_user.build_artist
                artist_params = profile_params[:artist].except(:genres)
                @artist.manager_id = nil 
                if @artist.update(artist_params)
                    if profile_params[:artist][:genres].present?
                         genres = find_or_create_genres(profile_params[:artist][:genres])
                         @artist.genres.replace(genres)
                    end
                else
                    render json: { errors: @artist.errors.full_messages }, status: :unprocessable_entity
                return
                end
            end

            render json: current_user, serializer: UserSerializer, from_artist: true, status: :ok
        end
        rescue Pundit::NotAuthorizedError => e
            render json: { error: "Not authorized to update profile", details: e.message }, status: :forbidden
        end

        private

        def profile_params
            allowed = [
                :first_name, :last_name, :email, :gender, :address, :dob, :phone_number,
                artist: [:first_release_year, :bio, :website, :photo, { social_media_links: {} }, { genres: [] }]
            ]
            params.require(:user).permit(allowed)
        end

        def user_params
            params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :gender, :address, :phone_number, :dob)
        end
        end
    end
end