class Quiz < ApplicationRecord
  belongs_to :user, optional: true
  has_many :quiz_questions, dependent: :destroy
  validates :completed, inclusion: { in: [true, false] }
  
  def self.fetch_logs_for_user(user, year: nil, month: nil)
    quizzes = user.quizzes.where(completed: true)

    if year.present? && month.present?
      start_date = Date.new(year.to_i, month.to_i, 1).beginning_of_day
      end_date = Date.new(year.to_i, month.to_i, -1).end_of_day
      quizzes = quizzes.where(start_time: start_date..end_date)
    end

    if quizzes.exists?
      quizzes.map do |quiz|
        {
          id: quiz.id,
          formatted_start_time: quiz.start_time.present? ? quiz.start_time.strftime('%Y-%m-%d %H:%M') : "不明",
          score: quiz.calculate_score,
          path: Rails.application.routes.url_helpers.play_quizzes_path(state: "results", id: quiz.id)
        }
      end
    else
      [{ message: "該当するクイズ履歴がありません。" }]
    end
  end

  # スコア計算
  def calculate_score
    total_questions = quiz_questions.count
    correct_answers = quiz_questions.where(correct: true).count
    "#{correct_answers}/#{total_questions}"
  end



end
