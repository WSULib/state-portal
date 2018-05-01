##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog

  configure_blacklight do |config|
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]
    config.view.embed.partials = [:index_header, :index]


    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'
    config.index.thumbnail_field = :full_image_url_ssm

    config.show.thumbnail_field = :full_image_url_ssm

    config.add_search_field 'all_fields', label: 'Everything'

    config.add_sort_field 'relevance', sort: 'score desc', label: 'Relevance'

    config.add_facet_field 'data_provider_ssim', label: 'Data Provider', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'collection_ssim', label: 'Collection', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'language_ssim', label: 'Language', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'type_ssim', label: 'Type', limit: 20, index_range: 'A'..'Z'
    # config.add_facet_field 'pub_date', label: 'Publication Year', single: true
    config.add_facet_field 'place_ssim', label: 'Place', limit: 20, index_range: 'A'..'Z'
    # config.add_facet_field 'subject', label: 'Subject', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'creator_ssim', label: 'Creator', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'format_ssim', label: 'Format'

    config.add_facet_fields_to_solr_request!

    config.add_index_field 'spotlight_upload_description_tesim', label: 'Abstract'
    config.add_index_field 'note_tesim', label: 'Notes'
    config.add_index_field 'date_issued_dr', label: 'Date Issued'
    config.add_index_field 'date_created_dr', label: 'Date Created'
    config.add_index_field 'data_provider_ssim', label: 'Data Provider'
    config.add_index_field 'collection_ssim', label: 'Collection'

    config.add_show_field 'collection_ssim', label: 'Collection', link_to_search: true
    config.add_show_field 'spotlight_upload_description_tesim', label: 'Abstract'
    config.add_show_field 'note_tesim', label: 'Notes'
    config.add_show_field 'date_issued_dr', label: 'Date Issued'
    config.add_show_field 'date_created_dr', label: 'Date Created'
    config.add_show_field 'place_ssim', label: 'Place', link_to_search: true
    config.add_show_field 'subject_topic_ssim', label: 'Subject Topic', link_to_search: true
    config.add_show_field 'subject_name_ssim', label: 'Subject Name', link_to_search: true
    config.add_show_field 'subject_genre_ssim', label: 'Subject Genre', link_to_search: true
    config.add_show_field 'subject_title_ssim', label: 'Subject Title', link_to_search: true
    config.add_show_field 'format_ssim', label: 'Format', link_to_search: true
    config.add_show_field 'language_ssim', label: 'Language'
    config.add_show_field 'data_provider_ssim', label: 'Data Provider', link_to_search: true
    config.add_show_field 'rights_tesim', label: 'Rights'
    config.add_show_field 'url_ssm', label: 'URL', helper_method: :solr_url_to_link

    config.add_field_configuration_to_solr_request!

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true
  end
end
