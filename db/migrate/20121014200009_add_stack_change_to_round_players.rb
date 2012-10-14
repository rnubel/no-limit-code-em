class AddStackChangeToRoundPlayers < ActiveRecord::Migration
  def change
    add_column :round_players, :stack_change, :integer
  end
end
