class AddCaptionToFeaturedImages < ActiveRecord::Migration[5.2]
  def change
    add_column :spotlight_sites, :masthead_caption, :string
    add_column :spotlight_sites, :masthead_caption_url, :string
  end
end
