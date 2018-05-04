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

# Server Docker setup

## Installation

* [Install Docker Machine](https://docs.docker.com/machine/install-machine/)
* Setup passwordless sudo for the [generic Docker Machine driver](https://docs.docker.com/machine/drivers/generic/)
* Create the Docker Machine on the server: `docker-machine create --driver generic --generic-ip-address=159.65.230.32 --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user=portal spotlight`
* Check if the machine you created exists: `docker-machine env spotlight`

## Initial setup

* Set up environment variables to remote docker machine: `eval $(docker-machine env spotlight)`
* Deploy the application: `docker-compose -p spotlight up --no-start`
* Create the Postgres database:
    * `docker-compose -p spotlight run web bundle exec rake db:create`
    * `docker-compose -p spotlight run web bundle exec rake db:migrate`
* Create initial admin user: `docker-compose -p spotlight run web bundle exec rake spotlight:initialize`
* Create default exhibit: `docker-compose -p spotlight run web bundle exec rake db:seed`
* Run the application in production mode: `docker-compose -p spotlight up -d`

## Initialize Solr core

* Copy base configuration files to the container: `docker cp -L solr/configsets/. $(docker ps -q -f "name=spotlight_solr"):/opt/solr/server/solr/configsets`
* Create the Solr core: `docker exec -it $(docker ps -q -f "name=spotlight_solr") solr create_core -c [CORE_NAME:(default: blacklight-core)] -d [CONFIG_NAME]`
    * CONFIG_NAME can be any folder name in `solr/configsets`. There is a set of config files for each data source to allow creation of multiple cores for different sources and sets: combine_test, wsudor_dpla, and full_michigan_state_portal

# Server Management

List containers: `docker ps`
SSH into container: `docker exec -t -i [CONTAINER_ID] /bin/bash`
Create Solr core: `docker exec -it $(docker ps -q -f "name=spotlight_solr") solr create_core -c blacklight-core -d spotlight`
Delete Solr core: `docker exec -it $(docker ps -q -f "name=spotlight_solr") solr delete -c blacklight-core`

# Adding a new configset

* Copy base configuration files to the container: `docker cp -L solr/configsets/. $(docker ps -q -f "name=spotlight_solr"):/opt/solr/server/solr/configsets`
* Create the Solr core: `docker exec -it $(docker ps -q -f "name=spotlight_solr") solr create_core -c [CORE_NAME:(default: blacklight-core)] -d [CONFIG_NAME]`
