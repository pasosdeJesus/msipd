require 'msipd/concerns/models/orgsocial'

module Msip
  class Orgsocial < ActiveRecord::Base 

    include Msipd::Concerns::Models::Orgsocial

  end
end
