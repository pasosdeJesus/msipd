source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

#gem 'byebug', group: [:development, :test]

gem 'cancancan'                  

gem 'devise' # Autenticación

gem 'devise-i18n'                

gem 'paperclip'                   # Anexos

gem 'rails-i18n'                 

gem 'simple_form'   # Formularios

gem 'twitter_cldr'                # Localiación e internacionalización

gem 'webpacker' # módulos en Javascript https://github.com/rails/webpacker

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

  gem 'simplecov'

end

