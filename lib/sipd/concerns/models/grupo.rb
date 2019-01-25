# encoding: UTF-8

require 'sip/concerns/models/grupo'

module Sipd
  module Concerns
    module Models
      module Grupo
        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Models::Grupo

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

#          validate :dominio_grupo
#          def dominio_grupo
#            if self.dominio.count < 0
#              errors.add(:dominio, 'Debe tener al menos un dominio')
#            else
#              sobran = self.dominio_id - 
#                current_ability.dominio_ids(current_usuario) 
#              if sobran.count > 0
#                errors.add(:dominio, 'No puede emplear los dominios ' + 
#                           sobran.inject(', '))
#              end
#            end
#          end
        end

      end
    end
  end
end

