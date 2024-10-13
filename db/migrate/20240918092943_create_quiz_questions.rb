class CreateQuizQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true
      t.string :user_answer
      t.boolean :correct, default: false 

      t.timestamps
    end
  end
end
