class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, length: { maximum: 10 }, presence: true

  validates :password, presence: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  has_one_attached :avatar
  has_many :quizzes, dependent: :destroy

  has_many :favorites, dependent: :destroy
  has_many :favorite_words, through: :favorites, source: :word

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
