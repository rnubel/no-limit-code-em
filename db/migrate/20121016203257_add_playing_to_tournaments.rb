class AddPlayingToTournaments < ActiveRecord::Migration
  def change
    add_column :tournaments, :playing, :boolean, :default => false
  end
end
