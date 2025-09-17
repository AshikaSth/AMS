class User < ApplicationRecord
    has_many :refresh_tokens, dependent: :destroy

    has_secure_password
    validates :email, presence: true, uniqueness: true
    enum :role, [:super_admin, :artist_manager, :artist]
    enum :gender, [:male, :female, :others]

end
