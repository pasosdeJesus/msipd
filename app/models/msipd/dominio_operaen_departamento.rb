require 'msipd/concerns/models/dominio_operaen_departamento'

module Msipd
  class DominioOperaenDepartamento < ActiveRecord::Base
    include Msipd::Concerns::Models::DominioOperaenDepartamento
  end
end
