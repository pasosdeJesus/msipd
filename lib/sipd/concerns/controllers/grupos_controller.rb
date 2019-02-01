# encoding: UTF-8

require 'bcrypt'

require 'sip/concerns/controllers/grupos_controller'

module Sipd
  module Concerns
    module Controllers
      module GruposController

        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Controllers::GruposController

          def atributos_index
            ["id", 
             "nombre",
             "dominio"
            ] +
            [ :usuario_ids => [] ]  +
            [ "observaciones", 
             "fechacreacion_localizada", 
             "habilitado"
            ]
          end

          def atributos_show
            r = [
              "id",
              "nombre",
              "dominio"
            ]
            r += [ :usuario_ids => [] ] 
            r += ["observaciones", 
                  "fechacreacion_localizada", 
                  "fechadeshabilitacion_localizada" 
            ]
            r
          end

          def atributos_form
            r = atributos_show - ["id"]
            # No perite agregar miembros a grupos totalmente nuevos
            # primero debe crearse
            if !@registro.nil? && !@registro.respond_to?('id')
              r = r - [ :usuario_ids => [] ] 
              # En new y edit @registro no es nil
              # En create y update @registro es nil
            end
            return r
          end

          def filtra_contenido_params
            # Limitamos dominios a los del usuario actual
            params[:grupo][:dominio_ids] &= 
              current_ability.dominio_ids(current_usuario).map(&:to_s)
            # Limitamos miembros a los administrados por el usuario actual,
            # es decir a los de los dominios
            params[:grupo][:usuario_ids] &= ::Usuario.joins(:dominio).where(
              "sipd_dominio.id" => current_ability.dominio_ids(current_usuario)
            ).pluck(:id).map(&:to_s)
          end

          # Validaciones adicionales a las del modelo que 
          # requieren current_usuario y current_ability y que
          # bien no se desean que generen una excepción o bien
          # que no se pudieron realizar con cancancan
          def validaciones(registro)
            if current_usuario.rol == Ability::ROLADMIN || 
                current_usuario.rol == Ability::ROLDIR
              if registro.dominio_ids.count <= 0
                registro.errors.add(:dominio, 'Debe tener al menos un dominio')
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
            r = atributos_form - ['sip_grupo'] + 
              [:sip_grupo_ids => []] - ['dominio'] +
              [:dominio_ids => []] 
            return r
          end

          def lista_params
            lista_params_sipd
          end

          # Lista blanca de paramétros
          def grupo_params
            params.require(:grupo).permit(lista_params)
          end

        end  # included

      end
    end
  end
end

