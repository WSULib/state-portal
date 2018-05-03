module Spotlight
  class UploadSolrDocumentBuilder < SolrDocumentBuilder
    delegate :compound_id, to: :resource

    def to_solr
      super.tap do |solr_hash|
        add_default_solr_fields solr_hash
        add_image_dimensions solr_hash
        add_file_versions solr_hash
        add_sidecar_fields solr_hash
        add_manifest_path solr_hash
      end
    end

    private

    def add_default_solr_fields(solr_hash)
      solr_hash[exhibit.blacklight_config.document_model.unique_key.to_sym] = compound_id
    end

    def add_image_dimensions(solr_hash)
      return unless is_image?
      dimensions = Riiif::Image.new(resource.upload_id).info
      solr_hash[:spotlight_full_image_width_ssm] = dimensions.width
      solr_hash[:spotlight_full_image_height_ssm] = dimensions.height
    end

    def add_file_versions(solr_hash)
      solr_hash[Spotlight::Engine.config.thumbnail_field] = riiif.image_path(resource.upload_id, size: '!400,400')
    end

    def add_sidecar_fields(solr_hash)
      solr_hash.merge! resource.sidecar.to_solr
    end

    def add_manifest_path(solr_hash)
      solr_hash[Spotlight::Engine.config.iiif_manifest_field] = spotlight_routes.manifest_exhibit_solr_document_path(exhibit, resource.compound_id)
    end

    def spotlight_routes
      Spotlight::Engine.routes.url_helpers
    end

    def riiif
      Riiif::Engine.routes.url_helpers
    end

    def is_image?
      Spotlight::Engine.config.allowed_image_extensions.include?(resource.upload.image.file.extension.downcase)
    end
  end

  module ExhibitDefaults
    extend ActiveSupport::Concern

    included do
      before_create :build_home_page
      before_create :add_site_reference
      after_create :initialize_config
      after_create :initialize_browse
      after_create :initialize_main_navigation
      after_create :initialize_filter
    end

    protected

    def initialize_filter
      return unless Spotlight::Engine.config.filter_resources_by_exhibit

      filters.create field: default_filter_field, value: default_filter_value
    end

    def initialize_config
      self.blacklight_configuration ||= Spotlight::BlacklightConfiguration.create!
    end

    def initialize_browse
      return unless searches.blank?

      searches.create title: 'All Exhibit Items',
                      long_description: 'All items in this exhibit.'
    end

    def initialize_main_navigation
      default_main_navigations.each_with_index do |nav_type, weight|
        main_navigations.create nav_type: nav_type, weight: weight
      end
    end

    def add_site_reference
      self.site ||= Spotlight::Site.instance
    end

    def default_filter_field
      'default_spotlight_collection'
    end

    # Return a string to work around any ActiveRecord type-casting
    def default_filter_value
      'true'
    end

    private

    def default_main_navigations
      Spotlight::Engine.config.exhibit_main_navigation.dup
    end
  end
end
