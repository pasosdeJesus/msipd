# encoding: UTF-8

require 'sip/concerns/models/actorsocial'

module Sipd
  module Concerns
    module Models
      module Actorsocial
        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Models::Actorsocial

          has_and_belongs_to_many :dominio, 
            class_name: 'Sipd::Dominio',
            foreign_key: "actorsocial_id", 
            validate: true,
            association_foreign_key: "dominio_id",
            join_table: 'sipd_actorsocial_dominio'

          scope :filtro_dominio, lambda {|d|
            joins(:dominio).where('sipd_dominio.id = ?', d)
          }

          #validate :dominio_actorsocial
          # Como esta validacion requiere current_usuario y current_ability
          # se hace en el controlador

        end #included
      end
    end
  end
end

