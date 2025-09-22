class Api::V1::AlbumsController < ApplicationController

    def index
        @albums=policy_scope(Album)
        render json: @albums, each_serializer: AlbumSerializer, status: :ok
    end

    # GET api/v1/users/[:id]
  def show
    @album = Album.find(params[:id])
    render json: @album, serializer: AlbumSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Album not found" }, status: :not_found
  end
    
    
    def create 
        artist=current_user.artist
        @album = artist.albums.build(album_params.except(:genres))
        authorize @album
        if album_params[:genres].present?
            genres = find_or_create_genres(album_params[:genres])
            @album.genres << genres
        end

        if @album.save 
            render json: @album, status: :created
        else 
            render json: {errors: @album.errors.full_messages}, status: :unprocessable_entity
        end
    end


    def update
      @album = Album.find(params[:id])
      authorize @album

      if album_params[:genres].present?
        genres = find_or_create_genres(album_params[:genres])
        @album.genres = genres # overwrite old associations
      end

      if @album.update(album_params.except(:genres))
        render json: @album, serializer: AlbumSerializer, status: :ok
      else
        render json: { errors: @album.errors.full_messages }, status: :unprocessable_entity
      end
    end


  # DELETE api/v1/albums/[:id]
  def destroy
    begin
      @album = Album.find(params[:id])
      authorize @album

      @album.destroy
      render json: { message: "Album deleted successfully" }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { errors: "Album not found" }, status: :not_found
    end
  end

    private 
    def album_params 
        params.require(:album).permit(
            :name, :release_date, :cover_art_url, :artist_ids;[], :created_at, :updated_at, genres:[], music_ids:[]
        )
    end

    def find_or_create_genres(genre_names)
        genre_names.map do |name|
        Genre.find_or_create_by!(name:name.strip.downcase)
        end
    end

    
end


