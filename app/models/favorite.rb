class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :word
  
  validates :user_id, uniqueness: { scope: :word_id }
end
