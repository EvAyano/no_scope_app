class AddPronunciationsToWords < ActiveRecord::Migration[7.1]
  def change
    add_column :words, :pronunciation_jp, :string
    add_column :words, :pronunciation_en, :string
  end
end
