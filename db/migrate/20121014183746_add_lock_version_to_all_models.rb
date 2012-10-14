class AddLockVersionToAllModels < ActiveRecord::Migration
  def change
    [:rounds, :tables, :tournaments, :players].each do |table|
      add_column table, :lock_version, :integer, :default => 0
    end
  end
end
