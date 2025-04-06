class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  belongs_to :word

  validates :quiz_id, presence: true
  validates :word_id, presence: true
  validates :correct, inclusion: { in: [true, false] }

  serialize :choices, coder: JSON

  def is_correct_answer?(user_answer)
    word.term == user_answer
  end

  def correctness_text
    correct ? '正解' : '不正解'
  end
end
