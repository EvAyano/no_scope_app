class Quiz < ApplicationRecord
  belongs_to :user, optional: true
  has_many :quiz_questions, dependent: :destroy
  validates :completed, inclusion: { in: [true, false] }
end
