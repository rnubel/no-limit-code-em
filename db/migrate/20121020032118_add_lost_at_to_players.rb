class AddLostAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :lost_at, :timestamp
  end
end
