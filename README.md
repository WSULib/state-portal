# Michigan Service Hub State Portal Project

## Deployment Instructions

## AUTOMATED DEPLOYMENT
* Clone repo. Install ansible on client machine. Run ansible deployment script. See [wiki](../../wiki) for details on this process. NB: This is the preferred deployment process.

## MANUAL DEPLOYMENT
### (OPTIONAL SECTION)
* [Install Docker Machine](https://docs.docker.com/machine/install-machine/)
* Setup passwordless sudo for the [generic Docker Machine driver](https://docs.docker.com/machine/drivers/generic/)
* Create the Docker Machine on the server: `docker-machine create --driver generic --generic-ip-address=PUT_YOUR_IP_HERE --generic-ssh-key ~/.ssh/id_rsa --generic-ssh-user=portal spotlight`
* Check if the machine you created exists: `docker-machine env spotlight`
* Set up environment variables to remote docker machine: `eval $(docker-machine env spotlight)`

## Initial setup

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

```
List containers status (2 ways listed below)
docker ps -a
docker container ls

Print your docker configuration file to the screen and list variables that are supposed to be inherited from .env file
docker-compose config

Stop all running containers.
docker stop $(docker ps -aq)

Kill all running containers.
docker kill $(docker ps -aq)

Remove all containers.
docker rm $(docker ps -aq)

Remove all images.
docker rmi $(docker images -q)

Tail log output for selected docker container
docker logs --follow spotlight_web_1

SSH (or run whatever command) in selected container
docker exec -it <container name> /bin/bash

Build and deploy all containers
docker-compose -p spotlight -f docker-compose.yml up --build -d

Stop all containers and Docker internal network
docker-compose -p spotlight down

Rebuild selected container to reflect latest changes (to remote Github repos and any changes in /opt/state-portal)
docker-compose -p spotlight -f docker-compose.yml up --build -d [CONTAINER_NAME]

Create Solr core
docker exec -it $(docker ps -q -f "name=spotlight_solr") solr create_core -c portal -d spotlight

Delete Solr core
docker exec -it $(docker ps -q -f "name=spotlight_solr") solr delete -c portal

```

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
# Adding a field to the dataset

* Add field to import config: `data-config.xml`
* Add field to schema: `schema.xml`
* Add field to index or show page: `catalog_controller.rb`

If you want to add the field to the search results list:

* Add field to `solrconfig.xml` in the `fl` section for the search requestHandler

* Reindex all the data
    * Reindex the data using either Solr DataImport handler inside the Solr app or trigger within Portal admin page

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
