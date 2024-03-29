require 'bcrypt'

require 'msip/concerns/controllers/usuarios_controller'
require 'msipd/concerns/controllers/msipd_controller'

module Msipd
  module Concerns
    module Controllers
      module UsuariosController

        extend ActiveSupport::Concern

        included do
          include Msip::Concerns::Controllers::UsuariosController
          include Msipd::Concerns::Controllers::SipdController

          def atributos_show
            r = [ "id" ]
            r << "dominio_ids"
            r += [
              "nusuario",
              "nombre",
              "descripcion",
              "rol",
              "email",
              "created_at_localizada",
              "fechadeshabilitacion_localizada"
            ]
            r
          end

          def atributos_form
            r = []
            r << "dominio"
            r += [ 
              "nusuario",
              "nombre",
              "descripcion",
              "rol",
              "email",
            ]
            if can?(:manage, Msip::Grupo)
              r += ["msip_grupo"]
            end
            r += [
              "idioma",
              "encrypted_password",
              "fechacreacion_localizada",
              "fechadeshabilitacion_localizada",
              "failed_attempts",
              "unlock_token",
              "locked_at"
            ]
          end

          def lista_params_msipd
            r = atributos_form - ['msip_grupo'] + 
              [:grupo_ids => []] - ['dominio'] +
              [:dominio_ids => []] 
            return r
          end

          def lista_params
            lista_params_msipd
          end

          # Lista blanca de paramétros
          def usuario_params
            params.require(:usuario).permit(lista_params)
          end

        end  # included

      end
    end
  end
end

