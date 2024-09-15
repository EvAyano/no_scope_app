class List < ApplicationRecord
  belongs_to :user
  has_many :list_words, dependent: :destroy
  has_many :words, through: :list_words
end
