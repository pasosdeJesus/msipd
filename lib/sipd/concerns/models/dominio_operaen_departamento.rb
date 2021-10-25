module Sipd
  module Concerns
    module Models
      module DominioOperaenDepartamento
        extend ActiveSupport::Concern

        included do
          self.table_name = 'sipd_dominio_operaen_departamento'

          belongs_to :dominio, class_name: 'Sipd::Dominio', 
            foreign_key: 'dominio_id'
          belongs_to :departamento, class_name: 'Sip::Departamento',
            foreign_key: 'departamento_id'

        end # included

      end
    end
  end
end
