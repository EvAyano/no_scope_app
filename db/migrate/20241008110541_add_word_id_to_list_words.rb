class AddWordIdToListWords < ActiveRecord::Migration[7.1]
  def change
    add_column :list_words, :word_id, :bigint
  end
end
