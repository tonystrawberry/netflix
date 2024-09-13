class CreateProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :avatar
      t.string :code, null: false

      t.timestamps
    end

    add_index :profiles, :code, unique: true
  end
end
