class RemoveExampleEnAndExampleJpFromWords < ActiveRecord::Migration[7.1]
  def change
    remove_column :words, :"example_en", :string
    remove_column :words, :"example_jp", :string
  end
end
