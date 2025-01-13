class HomeController < ApplicationController
  def index
    @recent_quizzes = Quiz.where(completed: true)
                          .order(start_time: :desc)
                          .limit(10)

    if @recent_quizzes.any?
      @partial_to_render = "recent_quizzes_with_data"
    else
      @partial_to_render = "recent_quizzes_no_data"
    end
  end
end
