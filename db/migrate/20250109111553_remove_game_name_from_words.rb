class RemoveGameNameFromWords < ActiveRecord::Migration[7.1]
  def change
    remove_column :words, :game_name, :string
  end
end
