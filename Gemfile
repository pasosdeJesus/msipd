source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

#gem 'byebug', group: [:development, :test]

gem 'cancancan'                  

gem 'devise' , '>= 4.7.2' # Autenticación

gem 'devise-i18n'                , '>= 1.9.2'

gem 'paperclip'                   # Anexos

gem 'rails-i18n'                 , '>= 6.0.0'

gem 'simple_form'   , '>= 5.0.2' # Formularios

gem 'twitter_cldr'                # Localiación e internacionalización

gem 'webpacker' , '>= 5.2.1' # módulos en Javascript https://github.com/rails/webpacker

gem 'will_paginate' # Pagina listados


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento 
# lógico y no alfabetico como las gemas anteriores) 

gem 'sip', # Motor generico
  git: 'https://github.com/pasosdeJesus/sip.git'
#gem 'sip', path: '../sip'


group :development, :test do
  gem 'colorize'

  #gem 'byebug'
end


group :test do

  gem "minitest"

  # Problemas con simplecov 0.18 que en travis genera:
  # Error: json: cannot unmarshal object into Go struct field input.coverage of type []formatters.NullInt
  # https://github.com/codeclimate/test-reporter/issues/418
  gem 'simplecov', '~> 0.10', '< 0.18'

end

