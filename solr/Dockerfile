FROM solr

RUN mkdir -p /opt/solr/contrib/oaipmh/lib
ADD plugins /opt/solr/contrib/oaipmh/lib
ARG GEOLOCATION_API_KEY
ENV GEOLOCATION_API_KEY=$GEOLOCATION_API_KEY
RUN echo SOLR_OPTS=\"\$SOLR_OPTS -Dgeolocation.api_key=$GEOLOCATION_API_KEY\" >> /opt/solr/bin/solr.in.sh
