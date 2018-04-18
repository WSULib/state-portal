module ApplicationHelper
  def solr_url_to_image options = {}
    image_tag options[:value].first
  end

  def solr_url_to_link options = {}
    link_to options[:value].first, options[:value].first, target: '_blank'
  end
end
