class AddAnteToRounds < ActiveRecord::Migration
  def change
    add_column :rounds, :ante, :integer
  end
end
