require 'msip/concerns/models/persona'

module Sipd
  module Concerns
    module Models
      module Persona
        extend ActiveSupport::Concern

        included do
          include Msip::Concerns::Models::Persona

          # Problema en listado porque solo presentaba un dominio
          # Al detener con byebug en 3
          # a=Msip::Orgsocial.find(3);
          #  self.id
          #  3
          # (byebug) a==self
          #  true           
          # a.dominio_ids
          #   [1, 2]  
          # self.dominio_ids
          #   [2]
          #
          #No ocurre en vista resumen ni en formulario
          #
          #NO se soluciona al usar has_many y otra con :trough pero
          #se atenua más facil porque si opera bien dominio_orgsocial
          #
          has_and_belongs_to_many :dominio, 
            class_name: 'Sipd::Dominio',
            foreign_key: 'persona_id', 
            validate: true,
            association_foreign_key: 'dominio_id',
            join_table: 'sipd_dominio_persona'
 
          #has_many :dominio_persona
          #  class_name: 'Sipd::DominioPersona',
          #  foreign_key: 'persona_id',
          #  validate: true
          #has_many :dominio, through: :dominio_persona,
          #  class_name: 'Sipd::Dominio'

          scope :filtro_dominio, lambda {|d|
            joins(:dominio).where('sipd_dominio.id = ?', d)
          }

          #validate :dominio_persona
          # Como esta validacion requiere current_usuario y current_ability
          # se hace en el controlador

          def presenta(atr)
            case atr.to_s
            when 'dominio'
              r = dominio.inject ("") { |memo, d|
                memo == '' ? d.dominio : memo + "; " + d.dominio
              }
              return r
            else
              presenta_gen(atr)
            end
          end
        end #included
      end
    end
  end
end

