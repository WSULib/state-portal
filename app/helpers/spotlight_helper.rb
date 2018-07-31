##
# Global Spotlight helpers
module SpotlightHelper
  include ::BlacklightHelper
  include Spotlight::MainAppHelpers
  include Spotlight::ExhibitHelpers

  def iiif_link?
    @document[Spotlight::Engine.config.iiif_field].present?
  end

  def has_thumbnail?
    @document[Spotlight::Engine.config.thumbnail_field].present?
  end
end
