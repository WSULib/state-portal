Blacklight::Controller.module_eval do
  def search_facet_path(options = {})
    opts = search_state
             .to_h
             .merge(action: "facet", only_path: true)
             .merge(options)
             .except(:page)
    url_for opts
  end
end
