FROM solr

RUN mkdir -p /opt/solr/contrib/oaipmh/lib
ADD plugins /opt/solr/contrib/oaipmh/lib
ARG GEOLOCATION_API_KEY
ARG IMPORT_TRIGGER_URL
ENV GEOLOCATION_API_KEY=$GEOLOCATION_API_KEY
ENV IMPORT_TRIGGER_URL=$IMPORT_TRIGGER_URL
RUN echo SOLR_OPTS=\"\$SOLR_OPTS -Dgeolocation.api_key=${GEOLOCATION_API_KEY} -Ddataimport.trigger_url=${IMPORT_TRIGGER_URL}\" >> /opt/solr/bin/solr.in.sh
