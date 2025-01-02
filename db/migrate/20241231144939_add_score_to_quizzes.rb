class AddScoreToQuizzes < ActiveRecord::Migration[7.1]
  def change
    add_column :quizzes, :score, :integer
  end
end
