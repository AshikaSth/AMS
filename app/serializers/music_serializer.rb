class MusicSerializer < ActiveModel::Serializer
  attributes :id, :title, :cover_art_url, :artist_ids, :album_ids, :genre_names, :created_at, :updated_at

  def artist_ids
    object.artists.pluck(:id)
  end

  def album_ids
    object.albums.pluck(:id)
  end

  def genre_names
    object.genres.pluck(:name)
  end
end
