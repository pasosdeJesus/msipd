require 'bcrypt'

require 'msip/concerns/controllers/grupos_controller'
require 'sipd/concerns/controllers/sipd_controller'

module Sipd
  module Concerns
    module Controllers
      module GruposController

        extend ActiveSupport::Concern

        included do
          include Msip::Concerns::Controllers::GruposController
          include Sipd::Concerns::Controllers::SipdController

          def atributos_show
            r = [
              :id,
              :nombre,
              :dominio
            ]
            r += [ :usuario_ids => [] ] 
            r += [
              :observaciones, 
              :fechacreacion_localizada, 
              :fechadeshabilitacion_localizada 
            ]
            r
          end

          def atributos_form
            r = atributos_show - [:id]
            # No perite agregar miembros a grupos totalmente nuevos
            # primero debe crearse
            if !@registro.nil? && !@registro.respond_to?('id')
              r = r - [ :usuario_ids => [] ] 
              # En new y edit @registro no es nil
              # En create y update @registro es nil
            end
            return r
          end

          #def filtra_contenido_params
            # Limitamos dominios a los del usuario actual
          #  params[:grupo][:dominio_ids] &= 
              #current_ability.dominio_ids(current_usuario).map(&:to_s)
            # Limitamos miembros a los administrados por el usuario actual,
            # es decir a los de los dominios
          #  params[:grupo][:usuario_ids] &= ::Usuario.joins(:dominio).where(
         #     "sipd_dominio.id" => current_ability.dominio_ids(current_usuario)
         #   ).pluck(:id).map(&:to_s)
         # end

          def lista_params_sipd
            r = atributos_form - ['msip_grupo'] + 
              [:msip_grupo_ids => []] - ['dominio'] +
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

