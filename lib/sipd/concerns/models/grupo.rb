require 'msip/concerns/models/grupo'

module Sipd
  module Concerns
    module Models
      module Grupo
        extend ActiveSupport::Concern

        included do
          include Msip::Concerns::Models::Grupo

          # Esta generando una asociación belongs_to
          has_and_belongs_to_many :dominio, 
            class_name: 'Sipd::Dominio',
            foreign_key: "grupo_id", 
            validate: true,
            association_foreign_key: "dominio_id",
            join_table: 'sipd_dominio_grupo'

          scope :filtro_dominio, lambda {|d|
            joins(:dominio).where('sipd_dominio.id = ?', d)
          }

          #validate :dominio_grupo
          # Como esta validacion requiere current_usuario y current_ability
          # se hace en el controlador

        end #included
      end
    end
  end
end

