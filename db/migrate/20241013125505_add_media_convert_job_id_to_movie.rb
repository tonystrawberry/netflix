class AddMediaConvertJobIdToMovie < ActiveRecord::Migration[7.2]
  def change
    add_column :movies, :media_convert_job_id, :string
  end
end
