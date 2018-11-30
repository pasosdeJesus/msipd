# encoding: UTF-8

require 'sipd/concerns/models/departamento_dominio'

module Sipd
  class DepartamentoDominio < ActiveRecord::Base
    include Sipd::Concerns::Models::DepartamentoDominio
  end
end
