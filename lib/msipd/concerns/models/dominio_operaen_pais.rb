module Msipd
  module Concerns
    module Models
      module DominioOperaenPais
        extend ActiveSupport::Concern

        included do
          self.table_name = 'msipd_dominio_operaen_pais'

          belongs_to :dominio, class_name: 'Msipd::Dominio', 
            foreign_key: 'dominio_id', optional: false
          belongs_to :pais, class_name: 'Msip::Pais',
            foreign_key: 'pais_id', optional: false

        end # included

      end
    end
  end
end
