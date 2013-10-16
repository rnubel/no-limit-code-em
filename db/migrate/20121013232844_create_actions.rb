class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :action
      t.integer :amount
      t.string :cards
      t.integer :player_id
      t.integer :round_id

      t.timestamps
    end
  end
end
