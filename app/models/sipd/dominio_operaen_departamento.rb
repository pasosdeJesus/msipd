require 'sipd/concerns/models/dominio_operaen_departamento'

module Sipd
  class DominioOperaenDepartamento < ActiveRecord::Base
    include Sipd::Concerns::Models::DominioOperaenDepartamento
  end
end
