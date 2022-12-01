require 'sipd/concerns/models/persona'

module Msip
  class Persona < ActiveRecord::Base 

    byebug
    include Sipd::Concerns::Models::Persona

  end
end
