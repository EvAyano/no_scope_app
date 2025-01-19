class Word < ApplicationRecord
  validates :term, presence: true
  validates :definition, presence: true
  validates :explanation, presence: true
  validates :example_en, presence: true
  validates :example_jp, presence: true
  validates :related_videos, allow_blank: true, format: { with: /\A[\w-]+\z/}
  validates :pronunciation_jp, presence: true
  validates :pronunciation_en, presence: true
end
