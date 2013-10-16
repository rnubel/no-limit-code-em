class AddPurseToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :purse, :integer
  end
end
