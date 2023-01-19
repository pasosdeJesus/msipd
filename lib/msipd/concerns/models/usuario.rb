require 'msip/concerns/models/usuario'

module Msipd
  module Concerns
    module Models
      module Usuario
        extend ActiveSupport::Concern

        included do
          include Msip::Concerns::Models::Usuario

          has_and_belongs_to_many :dominio, 
            class_name: 'Msipd::Dominio',
            foreign_key: "usuario_id", 
            association_foreign_key: "dominio_id",
            join_table: 'msipd_dominio_usuario',
            validate: true

          scope :filtro_dominio_ids, lambda {|d|
            joins(:dominio).where('msipd_dominio.id = ?', d)
          }

        end

      end
    end
  end
end

