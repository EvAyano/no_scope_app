class List < ApplicationRecord
  belongs_to :user
  has_many :list_words, dependent: :destroy
  has_many :words, through: :list_words

  validate :list_name_presence, on: :create
  validate :list_name_uniqueness, on: :create
  validate :list_count_limit, on: :create

  private

  def list_name_presence
    if name.blank?
      errors.add(:base, 'リスト名を入力してください。')
    end
  end

  def list_name_uniqueness
    if user.lists.exists?(name: name)
      errors.add(:base, '同じ名前のリストは作成できません。')
    end
  end

  def list_count_limit
    if user.lists.count >= 5
      errors.add(:base, 'リストの上限は５つです。')
    end
  end
end
