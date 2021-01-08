$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "sipd/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sipd"
  s.version     = Sipd::VERSION
  s.authors     = ["Vladimir Tamara"]
  s.email       = ["vtamara@pasosdeJesus.org"]
  s.homepage    = ""
  s.summary     = "Agrega dominio a sip"
  s.description = "Agrega dominio a sip"
  s.license     = "Dominio público de acuerdo a legislación colombiana"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENCIA.md", "Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency "sip"

  s.add_development_dependency "pg"
end
