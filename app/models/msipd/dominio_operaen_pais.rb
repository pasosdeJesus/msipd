require 'msipd/concerns/models/dominio_operaen_pais'

module Msipd
  class DominioOperaenPais < ActiveRecord::Base
    include Msipd::Concerns::Models::DominioOperaenPais
  end
end
