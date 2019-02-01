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
            r << "dominio_ids"
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
          def usuario_params
            params.require(:usuario).permit(lista_params)
          end

        end  # included

      end
    end
  end
end

