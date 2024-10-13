class AddMediaConvertStatusAndMediaConvertProgressPercentageToMovie < ActiveRecord::Migration[7.2]
  def change
    add_column :movies, :media_convert_status, :integer, default: 0, null: false
    add_column :movies, :media_convert_progress_percentage, :integer
  end
end
