require 'sipd/concerns/models/orgsocial'

module Sip
  class Orgsocial < ActiveRecord::Base 

    include Sipd::Concerns::Models::Orgsocial

  end
end
