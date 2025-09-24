class AlbumSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :name, :release_date,  :created_at, :updated_at, :cover_art_url, :artist_names

    def cover_art_url
    if object.cover_art.attached?
      Rails.logger.info "Generating cover_art_url for Album #{object.id}" # Added logging
      url_for(object.cover_art)
    else
      Rails.logger.info "No cover art attached for Album #{object.id}"
      nil
    end
  end

  def artist_names

    artists = object.artists.map do |artist|
      user = artist.user
      { artist_id: artist.id, first_name: user&.first_name, last_name: user&.last_name } if user
    end.compact

    if object.creator && !artists.any? { |a| a[:artist_id] == object.creator.id }
      creator_user = object.creator.user
      artists << { artist_id: object.creator.id, first_name: creator_user&.first_name, last_name: creator_user&.last_name } if creator_user
    end
    
    artists.map { |a| "#{a[:first_name]} #{a[:last_name]}" }.compact
  end
  has_many :genres, serializer: GenreSerializer
  has_many :artists, serializer: ArtistSerializer
  has_many :musics, serializer: MusicSerializer
end