class Album < ApplicationRecord
  has_one_attached :cover_art
  belongs_to :creator, class_name: "Artist", foreign_key: "artist_id", optional: true

  has_many :album_musics, dependent: :destroy
  has_many :musics, through: :album_musics

  def music_count
    music.count
  end
  has_many :album_artists, dependent: :destroy
  has_many :artists, through: :album_artists
  
  has_many :album_genres, dependent: :destroy
  has_many :genres, through: :album_genres


end
