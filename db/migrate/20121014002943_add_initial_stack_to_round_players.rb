class AddInitialStackToRoundPlayers < ActiveRecord::Migration
  def change
    add_column :round_players, :initial_stack, :integer
  end
end
