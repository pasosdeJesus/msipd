# encoding: UTF-8

require 'bcrypt'

require 'sip/concerns/controllers/usuarios_controller'

module Sipd
  module Concerns
    module Controllers
      module UsuariosController

        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Controllers::UsuariosController

          def atributos_index
            r = [ "id" ]
            if can? :manage, Sipd::Dominio
              r << "dominio_id"
            end
            r += [
              "nusuario",
              "nombre",
              "descripcion",
              "rol",
              "email",
              "created_at_localizada",
              "habilitado"
            ]
            r
          end

          def atributos_form
            r = []
            if can? :manage, Sipd::Dominio
              r << "dominio_id"
            end
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

          # Lista blanca de paramétros
          def usuario_params
            r = atributos_form - ['sip_grupo'] + 
              [:sip_grupo_ids => []]

            params.require(:usuario).permit(r)
              #:id, :nusuario, :password, 
              #:nombre, :descripcion, :oficina_id,
              #:rol, :idioma, :email, :encrypted_password, 
              #:fechacreacion_localizada, :fechadeshabilitacion_localizada, 
              #:reset_password_token, 
              #:reset_password_sent_at, :remember_created_at, :sign_in_count, 
              #:current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, 
              #:failed_attempts, :unlock_token, :locked_at,
              #:last_sign_in_ip, :etiqueta_ids => [],
              #:sip_grupo_ids => []
          end

        end  # included

      end
    end
  end
end

