require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = "http://#{ENV['APP_DOMAIN']}/"

SitemapGenerator::Interpreter.send :include, Rails.application.routes.url_helpers
SitemapGenerator::Interpreter.send :include, Spotlight::Engine.routes.url_helpers

SitemapGenerator::Sitemap.create do
  Spotlight::Sitemap.add_all_exhibits(self)
end
