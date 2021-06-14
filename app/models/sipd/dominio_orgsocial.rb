module Sipd
  class DominioOrgsocial < ActiveRecord::Base
    belongs_to :orgsocial, class_name: 'Sip::Orgsocial',
      foreign_key: 'orgsocial_id'
    belongs_to :dominio, class_name: 'Sipd::Dominio',
      foreign_key: 'dominio_id'
  end
end
