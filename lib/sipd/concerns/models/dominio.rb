module Sipd
  module Concerns
    module Models
      module Dominio
        extend ActiveSupport::Concern

        included do
          include Msip::Modelo 
          include Msip::Localizacion

          self.table_name = 'sipd_dominio'

          has_and_belongs_to_many :grupo, 
            class_name: 'Msip::Grupo', 
            foreign_key: "dominio_id", 
            validate: true,
            association_foreign_key: "grupo_id",
            join_table: 'sipd_dominio_grupo'

          has_and_belongs_to_many :operaen_pais, 
            class_name: 'Msip::Pais',
            foreign_key: "dominio_id", 
            validate: true,
            association_foreign_key: "pais_id",
            join_table: 'sipd_dominio_operaen_pais'

          has_and_belongs_to_many :operaen_departamento, 
            class_name: 'Msip::Departamento',
            foreign_key: "dominio_id", 
            validate: true, 
            association_foreign_key: "departamento_id",
            join_table: 'sipd_dominio_operaen_departamento'

          has_and_belongs_to_many :usuario, 
            class_name: '::Usuario', 
            foreign_key: "dominio_id", 
            validate: true,
            association_foreign_key: "usuario_id",
            join_table: 'sipd_dominio_usuario'

          validates :dominio, length: { maximum: 500 }
          validates :mandato, length: { maximum: 5000 }


          def presenta_nombre
            self.dominio
          end

        end # included

      end
    end
  end
end
