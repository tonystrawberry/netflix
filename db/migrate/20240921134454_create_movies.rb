class CreateMovies < ActiveRecord::Migration[7.2]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.date :released_on, null: false
      t.integer :publishing_status, null: false, default: 0
      t.integer :audience_type, null: false, default: 0
      t.integer :media_type, null: false, default: 0
      t.boolean :featured, null: false, default: false
      t.datetime :published_at

      t.timestamps
    end
  end
end
