# encoding: UTF-8

module Sipd
  module Concerns
    module Models
      module Dominio
        extend ActiveSupport::Concern

        included do
          include Sip::Modelo 
          include Sip::Localizacion

          self.table_name = 'sipd_dominio'

          has_many :dominio_pais, class_name: 'Sipd::DominioPais',
            foreign_key: "dominio_id", validate: true
          has_many :pais, class_name: 'Sip::Pais',
            through: :dominio_pais

          has_many :departamento_dominio, 
            class_name: 'Sipd::DepartamentoDominio',
            foreign_key: "dominio_id", validate: true, 
            dependent: :delete_all
          has_many :departamento, class_name: 'Sip::Departamento',
            through: :departamento_dominio

          has_many :usuario, class_name: '::Usuario', validate: true,
            dependent: :delete_all

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
