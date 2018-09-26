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
* Deploy the application: `docker-compose -p spotlight -f docker-compose.yml up --no-start`
* Create the Postgres database:
    * `docker-compose -p spotlight -f docker-compose.yml run app bundle exec rake db:create`
    * `docker-compose -p spotlight -f docker-compose.yml run app bundle exec rake db:migrate`
* Create initial admin user: `docker-compose -p spotlight -f docker-compose.yml run app bundle exec rake spotlight:initialize`
* Create default exhibit: `docker-compose -p spotlight -f docker-compose.yml run app bundle exec rake db:seed`
* Run the application in production mode: `docker-compose -p spotlight -f docker-compose.yml up -d`

## Initialize Solr core

* Copy base configuration files to the container: `docker cp -L solr/configsets/. $(docker ps -q -f "name=spotlight_solr"):/opt/solr/server/solr/configsets`
* Create the Solr core: `docker exec -it $(docker ps -q -f "name=spotlight_solr") solr create_core -c [CORE_NAME:(default: blacklight-core)] -d [CONFIG_NAME]`
    * CONFIG_NAME can be any folder name in `solr/configsets`. There is a set of config files for each data source to allow creation of multiple cores for different sources and sets: combine_test, wsudor_dpla, and full_michigan_state_portal

# Server Management

List containers: `docker ps`
SSH into container: `docker exec -t -i $(docker ps -q -f "name=spotlight_solr") /bin/bash`
Create Solr core: `docker exec -it $(docker ps -q -f "name=spotlight_solr") solr create_core -c blacklight-core -d spotlight`
Delete Solr core: `docker exec -it $(docker ps -q -f "name=spotlight_solr") solr delete -c blacklight-core`

# Adding a new configset

* Copy base configuration files to the container: `docker cp -L solr/configsets/. $(docker ps -q -f "name=spotlight_solr"):/opt/solr/server/solr/configsets`
* Create the Solr core: `docker exec -it $(docker ps -q -f "name=spotlight_solr") solr create_core -c [CORE_NAME:(default: blacklight-core)] -d [CONFIG_NAME]`

# Build and deploy all containers

`docker-compose -p spotlight -f docker-compose.yml up --build -d`

# Build and deploy new version of a container

`docker-compose -p spotlight -f docker-compose.yml up --build -d [CONTAINER_NAME]`

# Updating a core

* Updating schema using Solr API: https://lucene.apache.org/solr/guide/7_3/schema-api.html
    * Updating the schema usually requires a reindex of the data
```
curl -X POST -H 'Content-type:application/json' --data-binary '{
"replace-dynamic-field":{
   "name":"*_bbox",
   "type":"location_rpt",
   "stored":true,
   "indexed":true,
   "multiValued":true }
}' http://159.65.230.32:8983/solr/um/schema
```
* Updating `solrconfig.xml`: `docker cp -L solr/configsets/[CORE_NAME]/solrconfig.xml $(docker ps -q -f "name=spotlight_solr"):/opt/solr/server/solr/[CORE_NAME]/conf/solrconfig.xml`
* Reload core: https://lucene.apache.org/solr/guide/7_3/coreadmin-api.html#CoreAdminAPI-RELOAD
```
curl "http://159.65.230.32:8983/solr/admin/cores?action=RELOAD&core=[CORE_NAME]"
```

# Environment Variables

| Environment variable | Description |
| -------------------- | ----------- |
| RAILS_ENV | Sets the Rails environment. <br>Default: `development` |
| POSTGRES_PASSWORD | Database password for Rails |
| DATABASE_URL | Database connection string for Rails <br>Format: `postgresql://[POSTGRES_USER]:[POSTGRES_PASSWORD]@[POSTGRES_HOST]:[POSTGRES_PORT]/[DATABASE_PREFIX]?encoding=utf8` <br>Environment will be automatically appended to `DATABASE_PREFIX`. For example, `DATABASE_PREFIX=spotlight` and `RAILS_ENV=development` will use the `spotlight_development` database |
| GEOLOCATION_DATABASE_URL | Database JDBC connection string used by geolocation Solr plugin <br>Format: `postgresql://[POSTGRES_HOST]/[DATABASE_NAME]?user=[POSTGRES_USER]&password=[POSTGRES_PASSWORD]` |
| SECRET_TOKEN | Rails secret token |
| SOLR_URL | Used by Spotlight import management page to display status and import progress <br>Format: `http://solr:8983/solr/[SOLR_CORE]` |
| IMPORT_TRIGGER_URL | Rails restore endpoint triggered upon successful reindex |
| FEED_URL | Used by Spotlight import management page to calculate progress |
| SENTRY_DSN | Sentry.io API URL |
| UPLOAD_EXTENSIONS | Full list of allowed upload file extensions |
| IMAGE_EXTENSIONS | Subset of `UPLOAD_EXTENSIONS` for image files |
| GEOLOCATION_API_KEY | Google Geolocation API Key |
| SENDGRID_USERNAME | SendGrid username |
| SENDGRID_PASSWORD | SendGrid password |
| APP_DOMAIN | FQDN for application |
| APP_EMAIL | From email for system emails |
