class SolrManagementController < ApplicationController
  def index
    solr_response = Faraday.get("#{ENV['SOLR_URL']}/dataimport?command=status")
    solr_data = JSON.parse(solr_response.body)
    @completed = solr_data['statusMessages']['Total Rows Fetched'].to_f
    @status = solr_data['status']

    if @status != 'idle'
      feed_data = Faraday.get ENV['FEED_URL']
      @total = Nokogiri::XML(feed_data.body).css('resumptionToken').first['completeListSize'].to_f
    else
      @total = @completed
    end

    @progress = (@completed / @total * 100).round(0)
  end

  def update
    Faraday.get "#{ENV['SOLR_URL']}/dataimport?command=full-import&clean=false"
  end

  def reindex
    Faraday.get "#{ENV['SOLR_URL']}/dataimport?command=full-import&clean=true"
  end
end
