class Music < ApplicationRecord
  has_one_attached :cover_art
  has_one_attached :audio
  
  has_many :artist_musics, dependent: :destroy
  has_many :artists, through: :artist_musics

  has_many :album_musics, dependent: :destroy
  has_many :albums, through: :album_musics

  has_many :music_genres, dependent: :destroy
  has_many :genres, through: :music_genres

  belongs_to :creator, class_name: "Artist", foreign_key: "artist_id", optional: true
  
  validates :title, presence: true
end
