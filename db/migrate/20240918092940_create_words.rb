class CreateWords < ActiveRecord::Migration[7.1]
  def change
    create_table :words do |t|
      t.string :term, null: false
      t.string :definition, null: false
      t.string :explanation
      t.string :game_name

      t.timestamps
    end
  end
end
