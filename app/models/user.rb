class User < ApplicationRecord
    has_many :refresh_tokens, dependent: :destroy

    has_secure_password
    validates :email, presence: true, uniqueness: true
end
