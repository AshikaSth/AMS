class Api::V1::MusicsController < ApplicationController

  def index
    @musics=policy_scope(Music)
    render json: @musics, each_serializer: MusicSerializer, status: :ok
  end

  def show
    @music = Music.find(params[:id])
    render json: @music, serializer: MusicSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Music not found" }, status: :not_found
  
  end
      
  def create 
    @music = Music.new(music_params.except(:artist_ids, :album_ids, :genres))
    current_artist = current_user.artist

    unless current_artist
      return render json: {error: "Only artists can create music"}, status: :forbidden
    end
    @music.creator = current_artist

    requested_artist_ids = Array(music_params[:artist_ids]).map(&:to_i)
    requested_artist_ids << current_artist.id
    requested_artist_ids.uniq!

    valid_artist_ids = Artist.where(id: requested_artist_ids).pluck(:id)
    if valid_artist_ids.empty?
      return render json: {error: "No valid artist ids provided"}, status: :unprocessable_entity
    end
    @music.artist_ids = valid_artist_ids

    if music_params[:album_ids].present?
      requested_album_ids = Array(music_params[:album_ids]).map(&:to_i)
      valid_album_ids = Album.where(id: requested_album_ids).pluck(:id)
      @music.album_ids = valid_album_ids
    end

    if music_params[:genres].present?
        genres = find_or_create_genres(music_params[:genres])
        @music.genres = genres
    end

    authorize @music

    if @music.save 
      render json: @music, serializer: MusicSerializer, status: :created
    else 
      render json: {errors: @music.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    begin
      @music = Music.find(params[:id])
      authorize @music

      if music_params.key?(:artist_ids)
        collaborator_ids = Array(music_params[:artist_ids]).map(&:to_i)
        collaborator_ids << @music.creator.id 
        collaborator_ids.uniq! 
        @music.artist_ids = Artist.where(id: collaborator_ids).pluck(:id)
      end

      if music_params[:album_ids].present?
        @music.album_ids = Album.where(id: Array(music_params[:album_ids]).map(&:to_i)).pluck(:id)
      end

      if music_params[:genres].present?
        genres = find_or_create_genres(music_params[:genres])
         @music.genres = genres
      end

      if @music.update(music_params.except(:artist_ids, :album_ids, :genres))
        render json: @music, serializer: MusicSerializer, status: :ok
      else
        render json: { errors: @music.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Music not found" }, status: :not_found
    end
  end


  def destroy
    begin
      @music = Music.find(params[:id])
      authorize @music

      @music.destroy
      render json: { message: "Music deleted successfully" }, status: :ok
    rescue Pundit::NotAuthorizedError
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    rescue ActiveRecord::RecordNotFound
      render json: { errors: "Music not found" }, status: :not_found
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private 
  def music_params 
    params.require(:music).permit(
      :title,
      :cover_art_url,
      album_ids:[], 
      artist_ids:[], 
      genres:[]
      )
  end

  def find_or_create_genres(genre_names)
    genre_names.map do |name|
    Genre.find_or_create_by!(name:name.strip.downcase)
        end
  end

end


