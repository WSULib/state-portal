# Michigan Service Hub State Portal Project

## Environment Setup

* Install gems: `bundle install`
* Setup database:
    * Create database: `rake db:create`
    * Create tables: `rake db:migrate`
* Setup Solr:
    * Build OAIPMH-Solr plugin: `mvn package`
    * Create plugin folder in `solr-instance` directory: `mkdir -p ./solr-instance/contrib/oaipmh/lib`
    * Copy plugin jar to the plugin lib folder
    
## Running the environment

* Run Solr server: `bundle exec solr_wrapper`
* Optional: index some test data: `rake solr:marc:index_test_data`
* Run application: `rails server` 

## Importing data

* Visit the [Data Import](http://127.0.0.1:8983/solr/#/blacklight-core/dataimport//dataimport) page
* Execute the import

# Adding a field to the dataset

* Add field to import config: `data-config.xml`
* Add field to schema: `schema.xml`
* Add field to index or show page: `catalog_controller.rb`

If you want to add the field to the search results list:

* Add field to `solrconfig.xml` in the `fl` section for the search requestHandler

* Reindex all the data
    * Delete the Solr `blacklight-core`
    * Restart Solr to regenerate the core
    * Reindex the data: `http://127.0.0.1:8983/solr/#/blacklight-core/dataimport//dataimport`

