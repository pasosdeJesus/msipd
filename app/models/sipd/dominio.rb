# encoding: UTF-8

require 'sipd/concerns/models/dominio'

module Sipd
  class Dominio < ActiveRecord::Base
    include Sipd::Concerns::Models::Dominio
  end
end
