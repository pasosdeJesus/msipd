# encoding: UTF-8

require 'sipd/concerns/models/dominio_pais'

module Sipd
  class DominioPais < ActiveRecord::Base
    include Sipd::Concerns::Models::DominioPais
  end
end
