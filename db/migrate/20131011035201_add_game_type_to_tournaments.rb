class AddGameTypeToTournaments < ActiveRecord::Migration
  def change
    change_table :tournaments do |t|
      t.string :game_type, null: false # Normalization, shnormalization.
    end
  end
end
