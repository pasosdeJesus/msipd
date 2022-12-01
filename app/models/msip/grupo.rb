require 'sipd/concerns/models/grupo'

module Msip
  class Grupo < ActiveRecord::Base 

    include Sipd::Concerns::Models::Grupo

  end
end
