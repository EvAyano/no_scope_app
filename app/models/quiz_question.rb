class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  belongs_to :word
  
  serialize :choices, coder: JSON

  def correct?(user_answer)
    word.term == user_answer
  end

  def css_class
    correct ? 'result-correct' : 'result-incorrect'
  end
end
