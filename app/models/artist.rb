class Artist < ApplicationRecord
  belongs_to :user
  has_many :albums
  has_many :music, through: :albums
  def no_of_albums_released
    albums.count
  end

end
