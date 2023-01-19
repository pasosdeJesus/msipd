module Msipd
  class DominioOrgsocial < ActiveRecord::Base
    belongs_to :orgsocial, class_name: 'Msip::Orgsocial',
      foreign_key: 'orgsocial_id', optional: false
    belongs_to :dominio, class_name: 'Msipd::Dominio',
      foreign_key: 'dominio_id', optional: false
  end
end
