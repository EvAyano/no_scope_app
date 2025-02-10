class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, length: { maximum: 10 }, presence: true

  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  has_one_attached :avatar
  has_many :quizzes, dependent: :destroy

  has_many :favorites, dependent: :destroy
  has_many :favorite_words, through: :favorites, source: :word

  def display_avatar(width: 100, height: 100)
    if avatar.attached?
      avatar.variant(resize_to_limit: [width, height])
    else
      "user-default-image.png"
    end
  end

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
