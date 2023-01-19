module Msipd
  class DominioUsuario < ActiveRecord::Base
    belongs_to :dominio, class_name: 'Msipd::Dominio',
      foreign_key: 'dominio_id', optional: false
    belongs_to :usuario, class_name: 'Msip::Usuario',
      foreign_key: 'usuario_id', optional: false
  end
end
