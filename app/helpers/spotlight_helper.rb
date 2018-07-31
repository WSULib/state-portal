##
# Global Spotlight helpers
module SpotlightHelper
  include ::BlacklightHelper
  include Spotlight::MainAppHelpers

  def iiif_link?
    @document[Spotlight::Engine.config.iiif_field].present?
  end

  def has_thumbnail?
    @document[Spotlight::Engine.config.thumbnail_field].present?
  end

  def default_exhibit
    Spotlight::Exhibit.find_by_slug('default')
  end
end
