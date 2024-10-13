class AddChoicesToQuizQuestions < ActiveRecord::Migration[7.1]
  def change
    add_column :quiz_questions, :choices, :text
  end
end
