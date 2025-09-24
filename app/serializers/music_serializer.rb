class MusicSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :title, :created_at, :updated_at, :cover_art_url, :audio_file_url
  has_many :genres, serializer: GenreSerializer
  has_many :artists, serializer: ArtistSerializer
  has_many :albums, serializer: AlbumSerializer

  def cover_art_url
    if object.cover_art.attached?
      Rails.logger.info "Generating cover_art_url for Music #{object.id}" 
      url_for(object.cover_art) 
    else
      Rails.logger.info "No cover art attached for Music #{object.id}"
      nil
    end
  end

  def audio_file_url
    if object.audio.attached?
      Rails.logger.info "Generating audio_file_url for Music #{object.id}"
      url_for(object.audio) 
    else
      Rails.logger.info "No audio attached for Music #{object.id}"
      nil
    end
  end
end

