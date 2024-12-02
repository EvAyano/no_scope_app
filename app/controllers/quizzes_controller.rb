class QuizzesController < ApplicationController
  before_action :authenticate_user!, only: [:history]  

  def create
    @quiz = current_user ? current_user.quizzes.create(start_time: Time.current) : Quiz.create

    words = Word.order("RAND()").limit(10)
    words.each do |word|
      choices = Word.where.not(id: word.id).order("RAND()").limit(3).pluck(:term)
      @quiz.quiz_questions.create(word: word, user_answer: nil, choices: choices.push(word.term).shuffle)
    end
    redirect_to quiz_path(@quiz)
  end

  def show
    print"問題表示"

    @quiz = Quiz.find(params[:id])
  
    if @quiz.completed
      redirect_to results_quiz_path(@quiz) and return
    end
  
    if @quiz.quiz_questions.where(user_answer: nil).exists?
      @current_question = @quiz.quiz_questions.where(user_answer: nil).first
      @current_question_number = @quiz.quiz_questions.where("id < ?", @current_question.id).count + 1
      @view_state = :question
    end
  end

  def answer
    @quiz = Quiz.find(params[:id])
    question = @quiz.quiz_questions.find(params[:question_id])
    
    if params[:answer].blank?
      flash[:alert] = "選択肢を1つ選んでください。"
      redirect_to quiz_path(@quiz) and return
    end
    print"答え確認"

    question.update(user_answer: params[:answer], correct: question.correct?(params[:answer]))

    redirect_to show_per_answer_quiz_path(@quiz, question_id: question.id)
  end

  def show_per_answer
    @view_state = :answer
    @quiz = Quiz.find(params[:id])
    @question = @quiz.quiz_questions.find_by(id: params[:question_id])
    @current_question_number = @quiz.quiz_questions.where("id < ?", @question.id).count + 1
    print"答え表示"

    if @question.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found and return
    end
  
    if @question.correct
      @result_message = "正解です"
      else
      @result_message = "ざんねん！不正解です。"
    end

    #未回答の問題がまだあるかどうかを確認、すべて回答済みの場合はクイズを完了状態にして結果ページへいく
    if @quiz.quiz_questions.where(user_answer: nil).exists?
       @button_label = '次の問題へ進む'
       @next_link = quiz_path(@quiz)
    else
      @quiz.update(completed: true)
      @button_label = '結果をみる'
      @next_link = results_quiz_path(@quiz)
    end

    # #戻るボタン
    # if @current_question_number >= 2
    #   previous_question = @quiz.quiz_questions.where("id < ?", @question.id).last
    #   @back_link = show_per_answer_quiz_path(@quiz, question_id: previous_question.id)
    # else
    #   @back_link = quizzes_intro_path
    # end
  end

  #結果表示
  def results
    print"結果表示"
    @view_state = :results
    @quiz = Quiz.find(params[:id])
    @questions = @quiz.quiz_questions
    @show_start_time = @quiz.start_time.present? ? @quiz.start_time.strftime('%Y-%m-%d %H:%M') : "不明"
  end

  #クイズ履歴
  def history
    @quizzes_log = current_user.quizzes.where(completed: true).map do |quiz|
      {
        id: quiz.id,
        formatted_start_time: quiz.start_time.present? ? quiz.start_time.strftime('%Y-%m-%d %H:%M') : "不明",
        path: results_quiz_path(quiz)
      }
    end
  end
end
