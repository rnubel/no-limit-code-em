class AddIndicesTake2 < ActiveRecord::Migration
  def change
    add_index :rounds, :table_id
    add_index :rounds, :playing

    add_index :tables, :tournament_id
    add_index :tables, :playing

    add_index :players, :lost_at
    add_index :players, :tournament_id

    add_index :actions, :player_id
    add_index :actions, :round_id

    add_index :tournaments, :playing
  end
end
