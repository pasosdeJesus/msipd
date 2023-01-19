require 'msipd/concerns/models/usuario'

class Usuario < ActiveRecord::Base
  include Msipd::Concerns::Models::Usuario
end
