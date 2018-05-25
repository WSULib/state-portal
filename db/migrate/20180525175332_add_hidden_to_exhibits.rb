class AddHiddenToExhibits < ActiveRecord::Migration[5.1]
  def change
    add_column :spotlight_exhibits, :hidden, :boolean, default: false
  end
end
