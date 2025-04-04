class Quiz < ApplicationRecord
  belongs_to :user, optional: true
  has_many :quiz_questions, dependent: :destroy
  validates :completed, inclusion: { in: [true, false] }
  paginates_per 20
  
  #特定ユーザーのページネーションを適用したクイズ履歴
  #呼ばれた際に引数が渡されなかった場合は自動でnil（年月フィルターなし）
  def self.paginated_quizzes_for(user, year: nil, month: nil, page: 1)
    quizzes = user.quizzes.where(completed: true).order(start_time: :desc)
    if year.present? && month.present?
      start_date = Date.new(year.to_i, month.to_i, 1).beginning_of_day
      end_date = Date.new(year.to_i, month.to_i, -1).end_of_day
      quizzes = quizzes.where(start_time: start_date..end_date)
    end
    quizzes.page(page)
  end

  #コントローラから変数paginated_quizzes変数で渡され引数quizzes_batchで処理
  def self.fetch_logs_from_relation(quizzes_batch)
    if quizzes_batch.exists?
      quizzes_batch.map do |quiz|
        {
          id: quiz.id,
          formatted_start_time: quiz.display_start_time,
          score: quiz.display_score,
          path: Rails.application.routes.url_helpers.play_quizzes_path(state: "results", id: quiz.id)
        }
      end
    else
      [{ message: "該当するクイズ履歴がありません。" }]
    end
  end

  # スコア計算
  def calculate_and_save_score
    correct_answers = quiz_questions.where(correct: true).count
    update(score: correct_answers)
  end

  def display_score
    total_questions = quiz_questions.count
    "#{score || 0}/#{total_questions}"
  end

  def display_username
    if user_id.present?
      user.nickname
    else
      "ゲストユーザー"
    end
  end

  def display_start_time
    return "不明" unless start_time.present?
    start_time.in_time_zone('Tokyo').strftime("%Y-%m-%d %H:%M")
  end
end
