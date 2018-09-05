FROM ruby:2.5-alpine

# Install dependencies
RUN apk add --no-cache \
      git \
      build-base \
      nodejs \
      tzdata \
      postgresql-dev \
      imagemagick \
      curl-dev

# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ARG RAILS_ENV
ENV RAILS_ENV=$RAILS_ENV
ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN bundle exec rake RAILS_ENV=$RAILS_ENV DATABASE_URL=postgres:does_not_exist assets:precompile
