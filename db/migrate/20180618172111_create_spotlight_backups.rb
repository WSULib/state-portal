class CreateSpotlightBackups < ActiveRecord::Migration[5.2]
  def change
    create_table :spotlight_backups do |t|
      t.json :files
      t.json :messages

      t.timestamps
    end
  end
end
