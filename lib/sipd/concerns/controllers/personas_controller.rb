# encoding: UTF-8

require 'bcrypt'

require 'sip/concerns/controllers/personas_controller'

module Sipd
  module Concerns
    module Controllers
      module PersonasController

        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Controllers::PersonasController

          def atributos_show
            [ :id, 
              :dominio,
              :nombres,
              :apellidos,
              :anionac,
              :mesnac,
              :dianac,
              :sexo,
              :pais,
              :departamento,
              :municipio,
              :clase,
              :nacionalde,
              :tdocumento,
              :numerodocumento
            ]
          end

          # Validaciones adicionales a las del modelo que 
          # requieren current_usuario y current_ability y que
          # bien no se desean que generen una excepción o bien
          # que no se pudieron realizar con cancancan
          def validaciones(registro)
            if current_usuario.rol != Ability::ROLSUPERADMIN &&
               current_usuario.rol == Ability::ROLDESARROLLADOR
              if registro.dominio_ids.count <= 0
                registro.errors.add(:dominio, 
                                    'Debe tener al menos un dominio')
              else
                sobran = registro.dominio_ids - 
                  current_ability.dominio_ids(current_usuario) 
                if sobran.count > 0
                  registro.errors.add(:dominio, 
                                      'No puede emplear los dominios ' + 
                                      sobran.inject(', '))
                end
              end
            end
            return registro.errors.empty?
          end

          def lista_params_sipd
            r = atributos_form - [:dominio] +
              [ :dominio_ids => [] ]
            return r
          end

          def lista_params
            lista_params_sipd
          end

          # Lista blanca de paramétros
          def persona_params
            params.require(:persona).permit(lista_params)
          end

        end  # included

      end
    end
  end
end

