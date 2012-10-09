class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.boolean :open

      t.timestamps
    end
  end
end
