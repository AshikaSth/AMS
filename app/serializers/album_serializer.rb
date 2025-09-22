class AlbumSerializer < ActiveModel::Serializer
  attributes :id, :name, :release_date, :cover_art_url, :artist_ids, :music_ids, :genre_names,  :created_at, :updated_at

  def artist_ids
    object.artists.pluck(:id)
  end

  def music_ids
    object.musics.pluck(:id)
  end

  def genre_names
    object.genres.pluck(:name)
  end
end