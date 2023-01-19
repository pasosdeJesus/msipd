Dummy::Application.config.relative_url_root = ENV.fetch(
  'RUTA_RELATIVA', '/msipd')
Dummy::Application.config.assets.prefix = ENV.fetch(
  'RUTA_RELATIVA', '/msipd') + '/assets'
