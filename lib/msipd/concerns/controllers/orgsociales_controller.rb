require 'bcrypt'

require 'msip/concerns/controllers/orgsociales_controller'
require 'msipd/concerns/controllers/msipd_controller'

module Msipd
  module Concerns
    module Controllers
      module OrgsocialesController

        extend ActiveSupport::Concern

        included do
          include Msip::Concerns::Controllers::OrgsocialesController
          include Msipd::Concerns::Controllers::SipdController

          def atributos_show
            [ :id, 
              :dominio,
              :grupoper_id,
              { :sectororgsocial_ids => [] },
              :web,
              :telefono, 
              :fax,
              :pais,
              :direccion,
              :fechadeshabilitacion_localizada
            ]
          end

          def atributos_index
            atributos_show - [
              :fechadeshabilitacion_localizada,
              "fechadeshabilitacion_localizada" ] + [
              :habilitado
            ]
          end

          def atributos_form
            a = atributos_show - [:id]
            a[a.index(:grupoper_id)] = :grupoper
            return a
          end

          # Elimina sin presentar mensajes de error (necesario 
          # porque administradores sólo pueden guardar
          # una organización social con un dominio, y si se valida
          # que no tenga dominios antes de eliminar no podría eliminar).
          def destroy(mens = "", verifica_tablas_union=true)
            super(mens, false)
          end

          def lista_params_msipd
            r = atributos_form - [:grupoper, :dominio] +
              [ :pais_id,
                :dominio_ids => [],
                :grupoper_attributes => [
                  :id,
                  :nombre,
                  :anotaciones ] ] 
            return r
          end

          def lista_params
            lista_params_msipd
          end

          # Lista blanca de paramétros
          def orgsocial_params
            params.require(:orgsocial).permit(lista_params)
          end

        end  # included

      end
    end
  end
end

