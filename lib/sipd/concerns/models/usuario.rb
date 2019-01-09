# encoding: UTF-8

require 'sip/concerns/models/usuario'

module Sipd
  module Concerns
    module Models
      module Usuario
        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Models::Usuario

          has_and_belongs_to_many :dominio, 
            class_name: 'Sipd::Dominio',
            foreign_key: "usuario_id", 
            association_foreign_key: "dominio_id",
            join_table: 'sipd_dominio_usuario',
            validate: true

          scope :filtro_dominio_id, lambda {|d|
            joins(:dominio).where('sipd_dominio.id = ?', d)
          }

        end

      end
    end
  end
end

