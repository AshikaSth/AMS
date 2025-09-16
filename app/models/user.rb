class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true, uniqueness: true, format: {with: URI::mailTo::EMAIL_REGEXP, message: "Invalid email"}
    validates :password, length: {minimum: 8}, allow_nil: true
end
