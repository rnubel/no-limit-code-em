class AddTimestampsToRequestLog < ActiveRecord::Migration
  def change
    add_column :request_logs, :created_at, :timestamp
  end
end
