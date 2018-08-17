class AddCustomHomeUrlToExhibit < ActiveRecord::Migration[5.2]
  def change
    add_column :spotlight_exhibits, :home_url, :string
  end
end
