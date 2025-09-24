class Api::V1::ArtistsController < ApplicationController
    require 'csv'
    before_action :authorize_request, only: [:index, :public_show, :update, :destroy, :assign_manager, :create, :csv_import, :csv_export]
    before_action :set_artist, only: [:public_show, :update, :destroy, :assign_manager]
    before_action :authorize_artist, only: [:public_show, :update, :destroy]

    def index
        @artists=policy_scope(Artist).includes(:user, :manager, :genres, :albums, :musics).with_attached_photo
        render json: @artists, each_serializer: ArtistSerializer, status: :ok
    end


    def public_show
        artist = Artist.find(params[:id])
        render json: artist, serializer:    PublicArtistSerializer, status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Artist not found" }, status: :not_found
    end
    
    
    def create
    begin

      genres = artist_params[:genres]
      photo = artist_params[:photo]
      Rails.logger.info "Received photo: #{photo.inspect}"

      if current_user.artist?
        @artist = current_user.build_artist(artist_params.except(:genres, :photo))
        @artist.manager_id = nil
      else
        @artist = Artist.new(artist_params.except(:genres, :photo))
        @artist.manager_id = current_user.id if current_user.artist_manager?
      end
      
      authorize @artist

      if genres.present?
        @artist.genres = find_or_create_genres(genres)
      end
      
      if photo.present?
        @artist.photo.attach(photo)
      end

      if @artist.save
        render json: @artist, status: :created
      else
        render json: { errors: @artist.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end


def update
    begin
      @artist = Artist.find(params[:id])
      authorize @artist

      if artist_params[:genres].present?
        @artist.genres = find_or_create_genres(artist_params[:genres])
      end
      
      if artist_params[:photo].present?
        @artist.photo.purge if @artist.photo.attached?
        @artist.photo.attach(artist_params[:photo])
      end

      if @artist.update(artist_params.except(:genres, :photo))
        render json: @artist, serializer: ArtistSerializer, status: :ok
      else
        render json: { errors: @artist.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Artist not found" }, status: :not_found
    rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

    def destroy
        begin
            @artist = Artist.find(params[:id])
            authorize @artist

            @artist.destroy
            render json: { message: "Artist deleted successfully" }, status: :ok
        rescue ActiveRecord::RecordNotFound
            render json: { error: "Artist not found" }, status: :not_found
        rescue Pundit::NotAuthorizedError
            render json: { error: "You are not authorized to perform this action." }, status: :forbidden
        end
    end

    def csv_import
        begin
            authorize Artist, :csv_import?

            file = params[:file]
            unless file
                return render json: { error: "No file provided" }, status: :bad_request
            end

            imported = []
            errors = []

            CSV.foreach(file.path, headers: true) do |row|
                begin
                user = User.find_by(email: row['email'])

                unless user
                    user = User.create!(
                    first_name: row['first_name'],
                    last_name: row['last_name'],
                    email: row['email'],
                    password: row['password'],
                    role: row['role'] || 'artist'
                    )
                end

                artist = Artist.find_or_initialize_by(user_id: user.id)
                artist.bio = row['bio']
                artist.website = row['website']
                artist.manager_id = row['manager_id'] if row['manager_id'].present?

                if row['genres'].present?
                    genre_names = row['genres'].split(',').map(&:strip)
                    artist.genres = genre_names.map { |name| Genre.find_or_create_by!(name: name.downcase) }
                end

                if artist.save
                    imported << artist
                else
                    errors << { row: row.to_h, errors: artist.errors.full_messages }
                end

                rescue => e
                errors << { row: row.to_h, errors: [e.message] }
                end
            end

            render json: { imported: imported.count, errors: errors }, status: :ok
        rescue Pundit::NotAuthorizedError
            render json: { error: "You are not authorized to perform this action." }, status: :forbidden
        end
    end

    # GET /api/v1/artists/csv_export

    def csv_export
        begin
            authorize Artist, :csv_export?

            artists = policy_scope(Artist).includes(:user, :genres) 
            csv_data = CSV.generate(headers: true) do |csv|
            csv << ['First Name', 'Last Name', 'Email', 'Role', 'Bio', 'Website', 'Manager ID', 'Genres']

            artists.each do |artist|
                csv << [    
                    artist.user.first_name || 'null',
                    artist.user.last_name || 'null',
                    artist.user.email || 'null',
                    artist.user.role || 'null',     
                    artist.bio || 'null',
                    artist.website|| 'null',
                    artist.manager_id || 'null',
                    artist.genres.map(&:name).join(', ').presence || 'null',
                    ]
                end
            end

            send_data csv_data, filename: "artists-#{Date.today}.csv"
        rescue Pundit::NotAuthorizedError
            render json: { error: "You are not authorized to perform this action." }, status: :forbidden
        end
    end

    def my_artists
        @artists=policy_scope(Artist).includes(:user, :manager, :genres, :albums, :musics).with_attached_photo
        render json: @artists, each_serializer: ArtistSerializer, status: :ok
    end

   
    # PATCH /api/v1/artists/:id/assign_manager
    def assign_manager
        begin
            artist = Artist.find(params[:id])
            authorize artist, :assign_manager?

            manager_id = params[:manager_id]
            manager = User.find_by(id: manager_id, role: 'artist_manager')

            unless manager
                return render json: { error: "Manager not found or invalid role" }, status: :not_found
            end
                artist.manager_id = manager.id
            if artist.save
                render json: { message: "Manager assigned successfully", artist: artist }, status: :ok
            else
                render json: { errors: artist.errors.full_messages }, status: :unprocessable_entity
            end
        rescue Pundit::NotAuthorizedError
            render json: { error: "You are not authorized to perform this action." }, status: :forbidden
        end
    end

    private 
    def set_artist
        @artist = Artist.find(params[:id])
    end

    def authorize_artist
        authorize @artist
    end

    def artist_params 
        if params[:artist][:social_media_links].is_a?(String) && params[:artist][:social_media_links].present?
            parsed_social_media = JSON.parse(params[:artist][:social_media_links]) rescue {}
            params[:artist][:social_media_links] = parsed_social_media
        end

        allowed = [
      :first_release_year, :bio, :website, :photo,
      { social_media_links: {} },
      { genres: [] }
    ]

    if current_user.super_admin?
      allowed << :user_id
      allowed << :manager_id
    elsif current_user.artist_manager?
      allowed << :user_id
    end
        params.require(:artist).permit(allowed)
    end

    def find_or_create_genres(genre_names)
        genre_names.map do |name|
        Genre.find_or_create_by!(name: name.strip.downcase)
        end
    end    
end
