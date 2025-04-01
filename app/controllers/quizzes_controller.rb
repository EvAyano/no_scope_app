class QuizzesController < ApplicationController
  before_action :authenticate_user!, only: [:history]

  def play
    case params[:state]
    when 'new'
      @view_state = :intro
    when 'create'
      create_quiz
      redirect_to play_quizzes_path(state: 'question', id: @quiz.id) and return
    when 'question'

      load_question
      @view_state = :question

    when 'answer'
      process_answer
      return if @view_state == :question
  
    when 'results'
      @view_state = :results
      load_results
    else
      @view_state = :intro
    end
    render :play
  end

  #クイズ履歴
  def history
    # フィルターのURLをリロードなどquizzes/hisotory以外からのアクセスの時はフィルターをリセットする
    if (params[:year].present? || params[:month].present?) &&
        (request.referer.nil? || URI(request.referer).path != history_quizzes_path)
      redirect_to history_quizzes_path and return
    end

    year = params[:year]
    month = params[:month]
    page = params[:page] || 1
  
    #フィルターとページネーションを適用したクイズ履歴
    paginated_quizzes = Quiz.paginated_quizzes_for(current_user, year: year, month: month, page: page)

    #ビュー表示用データ
    @quizzes_log = Quiz.fetch_logs_from_relation(paginated_quizzes)
  
    @quizzes_pagination = paginated_quizzes
  
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
      
  def determine_next_state
    if @quiz.quiz_questions.where(user_answer: nil).exists?
      { next_state: 'question', button_label: '次へ進む' }
    else
      @quiz.update(completed: true)
      { next_state: 'results', button_label: '結果を見る' }
    end
  end
  


  private

  def create_quiz
    @quiz = if current_user
      current_user.quizzes.create(start_time: Time.current)
    else
      Quiz.create(start_time: Time.current)
    end
    

    words = Word.order("RAND()").limit(10)
    words.each do |word|
      choices = Word.where.not(id: word.id).order("RAND()").limit(3).pluck(:term)
      @quiz.quiz_questions.create(word: word, user_answer: nil, choices: choices.push(word.term).shuffle)
    end
  end

  def load_question
    @quiz = Quiz.find(params[:id])
    @current_question = @quiz.quiz_questions.where(user_answer: nil).first
    @current_question_number = @quiz.quiz_questions.where("id < ?", @current_question.id).count + 1 if @current_question

    if @quiz.completed || @current_question.nil?
      redirect_to play_quizzes_path(state: "results", id: @quiz.id) and return
    end
  end

  

  def process_answer
    @quiz = Quiz.find(params[:id])
    @question = @quiz.quiz_questions.find(params[:question_id])
    @current_question = @quiz.quiz_questions.where(user_answer: nil).first
    @current_question_number = @quiz.quiz_questions.where("id < ?", @current_question.id).count + 1 if @current_question

  
    if params[:answer].blank?
      flash.now[:alert] = "選択肢を1つ選んでください。"
      load_question
      @view_state = :question
      return
    end

      # 正誤判定
    is_correct = @question.correct?(params[:answer]) # モデルで
    @question.update(user_answer: params[:answer], correct: is_correct)

    # 正解・不正解メッセージを設定
    @result_message = is_correct ? "正解です！" : "ざんねん、不正解です。"

    @question.update(user_answer: params[:answer], correct: @question.correct?(params[:answer]))
    if @quiz.quiz_questions.where(user_answer: nil).empty?
      # 全て回答済みの場合、最後の結果表示へ
      @quiz.update(completed: true)
      @view_state = :answer 
      @next_state = 'results'
      @button_label = '結果を見る'
    else
      # 未回答の問題が残っている場合
      @view_state = :answer
      @next_state = 'question'
      @button_label = '次へ進む'
    end
  end

  def load_results
    @quiz = Quiz.find(params[:id])
    @questions = @quiz.quiz_questions
    @quiz.calculate_and_save_score
    @show_start_time = @quiz.start_time.present? ? @quiz.start_time.in_time_zone('Tokyo').strftime('%Y-%m-%d %H:%M') : "不明"
  end
end
