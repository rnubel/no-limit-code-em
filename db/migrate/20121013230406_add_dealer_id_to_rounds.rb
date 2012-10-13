class AddDealerIdToRounds < ActiveRecord::Migration
  def change
    add_column :rounds, :dealer_id, :integer
  end
end
