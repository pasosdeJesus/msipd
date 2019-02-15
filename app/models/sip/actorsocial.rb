# encoding: UTF-8

require 'sipd/concerns/models/actorsocial'

module Sip
  class Actorsocial < ActiveRecord::Base 

    include Sipd::Concerns::Models::Actorsocial

  end
end
