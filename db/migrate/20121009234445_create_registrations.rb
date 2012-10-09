class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :player_id
      t.integer :tournament_id

      t.timestamps
    end
  end
end
