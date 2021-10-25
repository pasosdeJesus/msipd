# Lo tipico de controladores que descienden de sipd

module Sipd
  module Concerns
    module Controllers
      module SipdController

        extend ActiveSupport::Concern

        included do

          def atributos_index
            atributos_show - [
              :fechadeshabilitacion_localizada,
              "fechadeshabilitacion_localizada" ] + [
              :habilitado
            ]
          end

          def atributos_show
            [
              :id,
              :nombre,
              :fechadeshabilitacion_localizada 
            ]
          end

          def atributos_form
            r = atributos_show - [:id, "id"]
            return r
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
                                      Sipd::Dominio.where(id: sobran).
                                      map(&:dominio).inject(', '))
                end
              end
            end
            return registro.errors.empty?
          end

          def lista_params_sipd
            r = atributos_form - ['dominio'] +
              [:dominio_ids => []] 
            return r
          end

          def lista_params
            lista_params_sipd
          end

          #def mimodelo_params
          #  params.require(:mimodelo).permit(lista_params)
          #end

        end  # included

      end
    end
  end
end

