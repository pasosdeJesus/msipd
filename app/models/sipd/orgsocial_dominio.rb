# encoding: UTF-8

module Sipd
  class OrgsocialDominio < ActiveRecord::Base
    belongs_to :orgsocial, class_name: 'Sip::Orgsocial',
      foreign_key: 'orgsocial_id'
    belongs_to :dominio, class_name: 'Sipd::Dominio',
      foreign_key: 'dominio_id'
  end
end
