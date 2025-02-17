class HomeController < ApplicationController
  helper_method :login_about_partial

  def index
    @recent_quizzes = Quiz.where(completed: true).order(start_time: :desc).limit(10)

    if @recent_quizzes.any?
      @partial_to_render = "recent_quizzes_with_data"
    else
      @partial_to_render = "recent_quizzes_no_data"
    end
  end

  private
        
  def login_about_partial
    user_signed_in? ? 'home/logged_in' : 'home/logged_out'
  end
end
