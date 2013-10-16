class AddIndices < ActiveRecord::Migration
  def change
    add_index :round_players, :round_id
    add_index :round_players, :player_id

    add_index :seatings,  :table_id
    add_index :seatings,  :player_id
    add_index :seatings,  :active
  end
end
