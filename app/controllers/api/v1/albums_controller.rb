class Api::V1::AlbumsController < ApplicationController

  def index
      @albums=policy_scope(Album)
      render json: @albums, each_serializer: AlbumSerializer, status: :ok
  end

  def show
    @album = Album.find(params[:id])
    render json: @album, serializer: AlbumSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Album not found" }, status: :not_found
  end
    
    
  def create 
    @album = Album.new(album_params.except(:artist_ids, :music_ids, :genres))
    current_artist = current_user.artist
    unless current_artist
      return render json: {error: "Only artists can create album"}, status: :forbidden
    end
    @album.creator = current_artist

    requested_artist_ids = Array(album_params[:artist_ids]).map(&:to_i)
    requested_artist_ids << current_artist.id
    requested_artist_ids.uniq!

    valid_artist_ids = Artist.where(id: requested_artist_ids).pluck(:id)
    if valid_artist_ids.empty?
      return render json: {error: "No valid artist ids provided"}, status: :unprocessable_entity
    end
    @album.artist_ids = valid_artist_ids

    if album_params[:music_ids].present?
      requested_music_ids = Array(album_params[:music_ids]).map(&:to_i)
      valid_music_ids = Music.where(id: requested_music_ids).pluck(:id)
      @album.music_ids = valid_music_ids
    end

    if album_params[:genres].present?
        genres = find_or_create_genres(album_params[:genres])
        @album.genres = genres
    end
    authorize @album

    if @album.save 
      render json: @album, serializer: AlbumSerializer, status: :created
    else 
      render json: {errors: @album.errors.full_messages}, status: :unprocessable_entity
    end
  end


  def update
    begin
      @album = Album.find(params[:id])
      authorize @album

      if album_params.key?(:artist_ids)
        collaborator_ids = Array(album_params[:artist_ids]).map(&:to_i)
        collaborator_ids << @album_.creator.id if @album_.creator
        collaborator_ids.uniq! 
        @album.artist_ids = Artist.where(id: collaborator_ids).pluck(:id)
      end

      if album_params[:music_ids].present?
        @album.album_ids = Music.where(id: Array(album_params[:music_ids]).map(&:to_i)).pluck(:id)
      end

      if album_params[:genres].present?
        genres = find_or_create_genres(album_params[:genres])
      end

      if @album.update(album_params.except(:artist_ids, :music_ids, :genres))
        render json: @album, serializer: AlbumSerializer, status: :ok
      else
        render json: { errors: @album.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Album not found" }, status: :not_found
    end
  end

  def destroy
    begin
      @album = Album.find(params[:id])
      authorize @album

      @album.destroy
      render json: { message: "Album deleted successfully" }, status: :ok
    rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    rescue ActiveRecord::RecordNotFound
      render json: { errors: "Album not found" }, status: :not_found
    end
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
  end

  private 
  def album_params 
      params.require(:album).permit(
          :name, :release_date, :cover_art_url, artist_ids:[], genres:[], music_ids:[]
      )
  end

  def find_or_create_genres(genre_names)
    genre_names.map do |name|
      Genre.find_or_create_by!(name:name.strip.downcase)
    end
  end  
end


