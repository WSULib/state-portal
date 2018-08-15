Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.excluded_exceptions = []
end
