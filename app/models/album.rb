class Album < ApplicationRecord

  has_many :album_musics, dependent: :destroy
  has_many :musics, through: :album_musics

  def music_count
    music.count
  end
  has_many :album_artists, dependent: :destroy
  has_many :artists, through: :album_artists
  
  has_many :album_genres, dependent: :destroy
  has_many :genres, through: :album_genres

  validates :name, presence: true
end
