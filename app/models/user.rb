class User < ApplicationRecord
    has_many :refresh_tokens, dependent: :destroy
    has_one :artist, dependent: :destroy
    enum :role, [:super_admin, :artist_manager, :artist]

    has_secure_password
    validates :email, presence: true, uniqueness: true
    enum :gender, [:male, :female, :others]

    has_many :managed_artists, class_name: 'Artist', foreign_key: 'manager_id'
end
