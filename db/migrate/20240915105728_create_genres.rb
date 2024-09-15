class CreateGenres < ActiveRecord::Migration[7.2]
  def change
    create_table :genres do |t|
      t.string :code, null: false
      t.string :key, null: false

      t.timestamps
    end

    add_index :genres, :code, unique: true
  end
end
