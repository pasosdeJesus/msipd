require 'msipd/concerns/models/dominio'

module Msipd
  class Dominio < ActiveRecord::Base
    include Msipd::Concerns::Models::Dominio
  end
end
