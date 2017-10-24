class Question < ApplicationRecord
  has_many :answers, dependent: :destroy

  validates :title, :body,  presence: true

  validates :title, :body,  uniqueness: true
end
