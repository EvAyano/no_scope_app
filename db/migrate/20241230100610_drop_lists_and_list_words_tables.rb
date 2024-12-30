class DropListsAndListWordsTables < ActiveRecord::Migration[7.1]
  def up
    remove_foreign_key :list_words, :lists
    remove_foreign_key :lists, :users

    drop_table :list_words
    drop_table :lists
  end

  def down
    create_table :lists do |t|
      t.references :user, foreign_key: true, null: false
      t.timestamps
    end

    create_table :list_words do |t|
      t.references :list, foreign_key: true, null: false
      t.timestamps
    end
  end
end