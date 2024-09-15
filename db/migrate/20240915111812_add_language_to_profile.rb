class AddLanguageToProfile < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :language, :integer, default: 0, null: false
  end
end
