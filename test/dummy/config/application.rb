require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "sipd"


module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.time_zone = 'America/Bogota'
    config.i18n.default_locale = :es
    config.x.formato_fecha = 'dd/M/yyyy'
    config.active_record.schema_format = :sql
    config.railties_order = [:main_app, Sip::Engine, :all]

  end
end

