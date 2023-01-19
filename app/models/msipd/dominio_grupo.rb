module Msipd
  class DominioGrupo < ActiveRecord::Base
    belongs_to :dominio, class_name: 'Msipd::Dominio',
      foreign_key: 'dominio_id', optional: false
    belongs_to :grupo, class_name: 'Msip::Grupo',
      foreign_key: 'grupo_id', optional: false
  end
end
