class CreateQuizzes < ActiveRecord::Migration[7.1]
  def change
    create_table :quizzes do |t|
      t.references :user, null: true, foreign_key: true
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
