# encoding: UTF-8

module Sipd
  class ActorsocialDominio < ActiveRecord::Base
    belongs_to :actorsocial, class_name: 'Sip::Actorsocial',
      foreign_key: 'actorsocial_id'
    belongs_to :dominio, class_name: 'Sipd::Dominio',
      foreign_key: 'dominio_id'
  end
end
