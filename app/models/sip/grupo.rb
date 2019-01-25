# encoding: UTF-8

require 'sipd/concerns/models/grupo'

module Sip
  class Grupo < ActiveRecord::Base 

    include Sipd::Concerns::Models::Grupo

  end
end
