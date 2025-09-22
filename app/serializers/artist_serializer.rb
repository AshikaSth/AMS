class ArtistSerializer < ActiveModel::Serializer
  attributes :id, :first_release_year, :bio, :website, :photo_url, :genres, :manager_id, :created_at, :updated_at, :no_of_albums_released

  has_many :genres
  has_many :albums
  has_many :musics
  belongs_to :user, serializer: UserSerializer
  belongs_to :manager, serializer: UserSerializer

end
