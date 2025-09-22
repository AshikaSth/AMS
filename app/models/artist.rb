class Artist < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: 'User', foreign_key: 'manager_id', optional: true

  has_many :album_artists, dependent: :destroy
  has_many :albums, through: :album_artists


  has_many :artist_musics, dependent: :destroy
  has_many :musics, through: :artist_musics

  has_many :artist_genres, dependent: :destroy
  has_many :genres, through: :artist_genres

  def no_of_albums_released
    albums.count
  end

end
