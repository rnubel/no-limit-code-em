class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.integer :table_id
      t.boolean :playing
      t.string :player_order
      t.string :deck

      t.timestamps
    end
  end
end
