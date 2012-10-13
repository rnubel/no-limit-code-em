class CreateRoundPlayers < ActiveRecord::Migration
  def up
    create_table :round_players do |t|
      t.integer :player_id
      t.integer :round_id
    end
  end

  def down
    drop_table :round_players
  end
end
