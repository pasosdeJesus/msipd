require 'sip/concerns/models/orgsocial'

module Sipd
  module Concerns
    module Models
      module Orgsocial
        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Models::Orgsocial


          # Problema en listado porque solo presentaba un dominio
          # Al detener con byebug en 3
          # a=Sip::Orgsocial.find(3);
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
          #has_and_belongs_to_many :dominio, 
          #  class_name: 'Sipd::Dominio',
          #  foreign_key: "orgsocial_id", 
          #  validate: true,
          #  association_foreign_key: "dominio_id",
          #  join_table: 'sipd_dominio_orgsocial'
 
          has_many :dominio_orgsocial, 
            class_name: 'Sipd::DominioOrgsocial',
            foreign_key: 'orgsocial_id',
            validate: true, dependent: :delete_all
          has_many :dominio, through: :dominio_orgsocial,
            class_name: 'Sipd::Dominio'
          scope :filtro_dominio, lambda {|d|
            joins(:dominio).where('sipd_dominio.id = ?', d)
          }

          #validate :dominio_orgsocial
          # Como esta validacion requiere current_usuario y current_ability
          # se hace en el controlador

          def presenta(atr)
            case atr.to_s
            when 'dominio'
              r = dominio_orgsocial.inject ("") { |memo, ad|
                memo == '' ? ad.dominio.dominio : memo + "; " + ad.dominio.dominio
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

