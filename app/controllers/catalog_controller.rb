##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include BlacklightMaps::ControllerOverride

  helper Openseadragon::OpenseadragonHelper
  before_action :set_paper_trail_whodunnit

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*'
    }

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight document requestHandler.
    #
    # config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    # }
    #
    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'
    config.index.display_type_field = Spotlight::Engine.config.display_type_field
    config.index.thumbnail_field = Spotlight::Engine.config.thumbnail_field

    config.view.gallery.partials = [:index_header, :index]
    # config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)

    ## blacklight-maps configuration default values
    config.view.maps.geojson_field = "geojson_ssim"
    config.view.maps.placename_property = "placename"
    config.view.maps.coordinates_field = "coordinates_bbox"
    config.view.maps.search_mode = "placename" # or "coordinates"
    config.view.maps.spatial_query_dist = 0.5
    config.view.maps.placename_field = "place_ssim"
    config.view.maps.facet_mode = "geojson" # or "coordinates"
    config.view.maps.tileurl = "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
    config.view.maps.mapattribution = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    config.view.maps.maxzoom = 18
    config.view.maps.show_initial_zoom = 5

    config.add_facet_field 'geojson_ssim', :limit => -2, :label => 'Coordinates', :show => false
    
    # add :show_maplet to the show partials array
    config.show.partials << :show_maplet

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar

    config.add_facet_field 'data_provider_ssim', label: 'Data Provider', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'collection_ssim', label: 'Collection', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'language_ssim', label: 'Language', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'type_ssim', label: 'Type', limit: 20, index_range: 'A'..'Z'
    # config.add_facet_field 'pub_date', label: 'Publication Year', single: true
    config.add_facet_field 'place_ssim', label: 'Place', limit: 20, index_range: 'A'..'Z'
    # config.add_facet_field 'subject', label: 'Subject', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'creator_ssim', label: 'Creator', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'format_ssim', label: 'Format'

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'spotlight_upload_description_tesim', label: 'Abstract'
    config.add_index_field 'note_tesim', label: 'Notes'
    config.add_index_field 'date_issued_dr', label: 'Date Issued'
    config.add_index_field 'date_created_dr', label: 'Date Created'
    config.add_index_field 'data_provider_ssim', label: 'Data Provider'
    config.add_index_field 'collection_ssim', label: 'Collection'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'full_image_url_ssm', label: 'Thumbnail', helper_method: :solr_url_to_image
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

    config.add_search_field 'all_fields', label: 'Everything'

    config.add_sort_field 'relevance', sort: 'score desc', label: 'Relevance'
  end
end
