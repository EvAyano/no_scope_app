class CreateListWords < ActiveRecord::Migration[7.1]
  def change
    create_table :list_words do |t|
      t.references :list, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true

      t.timestamps
    end
  end
end
