class Api::V1::ArtistsController < ApplicationController
    def create 
        @artist = current_user.build_artist(artist_params.except(:genres))

        if artist_params[:genres].present?
            genres = find_or_create_genres(artist_params[:genres])
            @artist.genres << genres
        end

        if @artist.save 
            render json: @artist, status: :created
        else 
            render json: {errors: @artist.error.full_messages}, status: :unprocessable_entity
        end
    end
    def update 
    
    end

    private 
    def artist_params 
        params.require(:artist).permit(
            :first_relese_year, :bio, :website, :photo_url, social_media_links: {}, genres: []
        )
    end

    def find_or_create_genres(genre_names)
        genre_names.map do |name|
        Genre.find_or_create_by!(name: name)
        end
    end

    before_action :authorize_request

    def my_artists
        # This will return a list of all artists managed by the current user
        if current_user.role == 'artist_manager'
        @artists = current_user.managed_artists
        render json: @artists, status: :ok
        else
        render json: { error: 'You are not authorized to view this page' }, status: :unauthorized
        end
    end
    
end
