require 'sipd/concerns/models/dominio_operaen_pais'

module Sipd
  class DominioOperaenPais < ActiveRecord::Base
    include Sipd::Concerns::Models::DominioOperaenPais
  end
end
