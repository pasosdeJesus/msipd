# encoding: UTF-8

module Sipd
  module Concerns
    module Models
      module DominioOperaenPais
        extend ActiveSupport::Concern

        included do
          self.table_name = 'sipd_dominio_operaen_pais'

          belongs_to :dominio, class_name: 'Sipd::Dominio', 
            foreign_key: 'dominio_id'
          belongs_to :pais, class_name: 'Sip::Pais',
            foreign_key: 'pais_id'

        end # included

      end
    end
  end
end
