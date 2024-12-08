class QuizzesController < ApplicationController
  before_action :authenticate_user!, only: [:history]


  def play
    case params[:state]
    when 'new'
      @view_state = :intro
    when 'create'
      create_quiz
      redirect_to play_quizzes_path(state: 'question', id: @quiz.id) and return
      print "デバッグ"
      print(@view_state)
    when 'question'
      print "questionに行きます"

      load_question
      @view_state = :question

    when 'answer'
      print"answerケース"
      process_answer
      return if @view_state == :question
  
    when 'results'
      print"resultステータス"
      @view_state = :results
      load_results
    else
      @view_state = :intro
    end
    render :play
  end

  #クイズ履歴
  def history
    @quizzes_log = current_user.quizzes.where(completed: true).map do |quiz|
      {
        id: quiz.id,
        formatted_start_time: quiz.start_time.present? ? quiz.start_time.strftime('%Y-%m-%d %H:%M') : "不明",
        path: play_quizzes_path(state: "results", id: quiz.id)
      }
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
    @quiz = current_user ? current_user.quizzes.create(start_time: Time.current) : Quiz.create

    words = Word.order("RAND()").limit(10)
    words.each do |word|
      choices = Word.where.not(id: word.id).order("RAND()").limit(3).pluck(:term)
      @quiz.quiz_questions.create(word: word, user_answer: nil, choices: choices.push(word.term).shuffle)
    end
    print"クリエイトの中身！"
  end

  def load_question
    print"questionの中身"
    @quiz = Quiz.find(params[:id])
    @current_question = @quiz.quiz_questions.where(user_answer: nil).first
    @current_question_number = @quiz.quiz_questions.where("id < ?", @current_question.id).count + 1 if @current_question

    if @quiz.completed || @current_question.nil?
      redirect_to play_quizzes_path(state: "results", id: @quiz.id) and return
    end
  end

  

  def process_answer
    print"answerの中身"
    @quiz = Quiz.find(params[:id])
    @question = @quiz.quiz_questions.find(params[:question_id])
    @current_question = @quiz.quiz_questions.where(user_answer: nil).first
    @current_question_number = @quiz.quiz_questions.where("id < ?", @current_question.id).count + 1 if @current_question

  
    if params[:answer].blank?
      print "answerがnil"
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
    @show_start_time = @quiz.start_time.present? ? @quiz.start_time.strftime('%Y-%m-%d %H:%M') : "不明"
  end  
end
