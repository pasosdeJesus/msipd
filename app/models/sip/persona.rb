# encoding: UTF-8

require 'sipd/concerns/models/persona'

module Sip
  class Persona < ActiveRecord::Base 

    byebug
    include Sipd::Concerns::Models::Persona

  end
end
