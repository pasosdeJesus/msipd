require 'msipd/concerns/models/persona'

module Msip
  class Persona < ActiveRecord::Base 

    byebug
    include Msipd::Concerns::Models::Persona

  end
end
