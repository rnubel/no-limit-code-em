class CreateRequestLog < ActiveRecord::Migration
  def change
    create_table :request_logs do |t|
      t.integer :player_id
      t.integer :round_id
      t.text :body
    end
  end
end
