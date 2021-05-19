class CreateMenus < ActiveRecord::Migration[6.1]
  def change
    create_table :menus do |t|
      t.integer :position
      t.integer :genre, null: false
      t.string :name, null: false
      t.string :price, null: false

      t.timestamps
    end
  end
end
