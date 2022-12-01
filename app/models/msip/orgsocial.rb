require 'sipd/concerns/models/orgsocial'

module Msip
  class Orgsocial < ActiveRecord::Base 

    include Sipd::Concerns::Models::Orgsocial

  end
end
