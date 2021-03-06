class User < ApplicationRecord
  has_secure_password
  has_many :answers
  has_many :questions

  enum state: [:unconfirmed, :confirmed]

  validates :first_name, :last_name, presence: true

  validates :email, presence: true,
                  uniqueness: { case_sensitive: false },
                      length: { maximum: 255 },
                      format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }
end
