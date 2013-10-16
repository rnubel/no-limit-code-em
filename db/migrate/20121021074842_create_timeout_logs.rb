class CreateTimeoutLogs < ActiveRecord::Migration
  def change
    create_table :timeout_logs do |t|
      t.integer :player_id
      t.integer :round_id
      t.float :idle_time

      t.timestamps
    end
  end
end
