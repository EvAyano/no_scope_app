class List < ApplicationRecord
  belongs_to :user
  has_many :list_words, dependent: :destroy
  has_many :words, through: :list_words

  validate :list_count_limit, on: :create

  private

  def list_count_limit
    if user.lists.count >= 5
      errors.add(:base, 'リストの上限は５つです。')
      Rails.logger.debug("デバック: リストの上限は５つです。")
    end
  end
end

