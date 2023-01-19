require 'msipd/concerns/models/grupo'

module Msip
  class Grupo < ActiveRecord::Base 

    include Msipd::Concerns::Models::Grupo

  end
end
