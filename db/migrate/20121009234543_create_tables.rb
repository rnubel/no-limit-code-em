class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      t.integer :tournament_id
      t.boolean :playing
      t.string :seat_order

      t.timestamps
    end
  end
end
