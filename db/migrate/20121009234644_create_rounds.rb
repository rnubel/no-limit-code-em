class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.integer :table_id
      t.boolean :playing
      t.integer :dealer_id
      t.string :deck

      t.timestamps
    end
  end
end
