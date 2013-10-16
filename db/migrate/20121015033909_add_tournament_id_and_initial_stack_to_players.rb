class AddTournamentIdAndInitialStackToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :tournament_id, :integer
    add_column :players, :initial_stack, :integer
  end
end
