class AddIndexOnPlayerKeys < ActiveRecord::Migration
  def up
    add_index :players, :key
  end

  def down
    drop_index :players, :key
  end
end
