class AddCurrentStackToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :current_stack, :integer
  end
end
