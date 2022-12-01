module Sipd
  module Concerns
    module Models
      module DominioOperaenDepartamento
        extend ActiveSupport::Concern

        included do
          self.table_name = 'sipd_dominio_operaen_departamento'

          belongs_to :dominio, class_name: 'Sipd::Dominio', 
            foreign_key: 'dominio_id', optional: false
          belongs_to :departamento, class_name: 'Msip::Departamento',
            foreign_key: 'departamento_id', optional: false

        end # included

      end
    end
  end
end
