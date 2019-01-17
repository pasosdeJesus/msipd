# encoding: UTF-8

require 'sipd/concerns/models/dominio_operaen_pais'

module Sipd
  class DominioOperanePais < ActiveRecord::Base
    include Sipd::Concerns::Models::DominioOperaenPais
  end
end
