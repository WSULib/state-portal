module Spotlight
  class FeaturedImageUploader < CarrierWave::Uploader::Base
    storage Spotlight::Engine.config.uploader_storage

    def extension_whitelist
      Spotlight::Engine.config.allowed_upload_extensions + Spotlight::Engine.config.allowed_file_extensions
    end

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end

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
      Spotlight::Engine.config.allowed_upload_extensions.include?(resource.upload.image.file.extension.downcase)
    end
  end
end
