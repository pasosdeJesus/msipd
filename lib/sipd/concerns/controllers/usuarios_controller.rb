require 'bcrypt'

require 'sip/concerns/controllers/usuarios_controller'
require 'sipd/concerns/controllers/sipd_controller'

module Sipd
  module Concerns
    module Controllers
      module UsuariosController

        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Controllers::UsuariosController
          include Sipd::Concerns::Controllers::SipdController

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
            if can?(:manage, Sip::Grupo)
              r += ["sip_grupo"]
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
          def usuario_params
            params.require(:usuario).permit(lista_params)
          end

        end  # included

      end
    end
  end
end

