class AddBackupsToExhibits < ActiveRecord::Migration[5.2]
  def change
    add_column :spotlight_exhibits, :backups, :json
  end
end
