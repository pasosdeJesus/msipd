$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "msipd/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "msipd"
  s.version     = Msipd::VERSION
  s.authors     = ["Vladimir Tamara"]
  s.email       = ["vtamara@pasosdeJesus.org"]
  s.homepage    = ""
  s.summary     = "Agrega dominio a msip"
  s.description = "Agrega dominio a msip"
  s.license     = "Dominio público de acuerdo a legislación colombiana"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENCIA.md", "Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency "msip"

  s.add_development_dependency "pg"
end
