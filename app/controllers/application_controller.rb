class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  helper_method :is_gallery_view?
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller

  layout 'blacklight'

  protect_from_forgery with: :exception
  before_action :set_raven_context

  private

  def set_raven_context
    Raven.user_context(id: current_user.id) if current_user
  end

  def is_gallery_view?(context, *args)
    params.dig(:view) == 'gallery'
  end
end
