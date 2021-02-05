Dummy::Application.config.relative_url_root = ENV.fetch(
  'RUTA_RELATIVA', '/sipd')
Dummy::Application.config.assets.prefix = ENV.fetch(
  'RUTA_RELATIVA', '/sipd') + '/assets'
