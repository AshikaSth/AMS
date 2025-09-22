class AlbumSerializer < ActiveModel::Serializer
  attributes  :name, :release_date, :cover_art_url, :artist_id, :created_at, :updated_at, :genres

  has_many :artists
  has_many :musics
  has_many :genres
end