module Sipd
  class DominioGrupo < ActiveRecord::Base
    belongs_to :dominio, class_name: 'Sipd::Dominio',
      foreign_key: 'dominio_id', optional: false
    belongs_to :grupo, class_name: 'Sip::Grupo',
      foreign_key: 'grupo_id', optional: false
  end
end
