class AddStartTimeToQuizzes < ActiveRecord::Migration[7.1]
  def change
    add_column :quizzes, :start_time, :datetime
  end
end
