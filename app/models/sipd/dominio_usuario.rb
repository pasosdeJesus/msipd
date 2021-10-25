module Sipd
  class DominioUsuario < ActiveRecord::Base
    belongs_to :dominio, class_name: 'Sipd::Dominio',
      foreign_key: 'dominio_id'
    belongs_to :usuario, class_name: 'Sip::Usuario',
      foreign_key: 'usuario_id'
  end
end
