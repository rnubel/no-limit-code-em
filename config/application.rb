require File.expand_path('../boot', __FILE__)
require 'rack/throttle'

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

class ClientLimiter < Rack::Throttle::Interval
  def client_identifier(request)
    # Attempt to grab key from path.
    match = request.path.match(/\/api\/players\/([a-zA-Z0-9\-]{32,36})/)
    match && match[1]
  end

  def allowed?(request)
    return true unless client_identifier(request)
    return true if request.path =~ /action/
    t1 = request_start_time(request)
    t0 = cache_get(key = cache_key(request)) rescue nil
    allowed = !t0 || (dt = t1 - t0.to_f) >= minimum_interval
    Rails.logger.info "RATE LIMIT CHECK FOR key=#{client_identifier(request)} with t1=#{t1} t0=#{t0.to_f} delta #{dt} versus #{minimum_interval}, allowed=#{allowed}"
    begin
      cache_set(key, t1) if allowed
      allowed
    rescue => e
      # If an error occurred while trying to update the timestamp stored
      # in the cache, we will fall back to allowing the request through.
      # This prevents the Rack application blowing up merely due to a
      # backend cache server (Memcached, Redis, etc.) being offline.
      allowed = true
    end
  end
end

module NoLimitV2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.middleware.use ClientLimiter, :min => 0.8

    # Cache things.
    config.cache_store = :memory_store

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
