class AddExamplesToWords < ActiveRecord::Migration[7.1]
  def change
    add_column :words, :example_en, :string
    add_column :words, :example_jp, :string
  end
end
