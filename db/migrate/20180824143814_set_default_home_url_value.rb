class SetDefaultHomeUrlValue < ActiveRecord::Migration[5.2]
  def change
    change_column :spotlight_exhibits, :home_url, :string, default: ''
  end
end
