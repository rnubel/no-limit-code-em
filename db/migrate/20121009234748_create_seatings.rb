class CreateSeatings < ActiveRecord::Migration
  def change
    create_table :seatings do |t|
      t.integer :player_id
      t.integer :table_id
      t.boolean :active

      t.timestamps
    end
  end
end
