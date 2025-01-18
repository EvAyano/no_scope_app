class AddRelatedVideosToWords < ActiveRecord::Migration[7.1]
  def change
    add_column :words, :related_videos, :string
  end
end
