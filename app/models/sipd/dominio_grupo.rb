# encoding: UTF-8

module Sipd
  class DominioGrupo < ActiveRecord::Base
    belongs_to :dominio, class_name: 'Sipd::Dominio',
      foreign_key: 'dominio_id'
    belongs_to :grupo, class_name: 'Sip::Grupo',
      foreign_key: 'grupo_id'
  end
end
