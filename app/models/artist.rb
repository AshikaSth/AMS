class Artist < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: 'User'

  has_many :albums
  has_many :music, through: :albums
  has_many :artist_genres
  has_many :genres, through: :artist_genres

  def no_of_albums_released
    albums.count
  end

end
