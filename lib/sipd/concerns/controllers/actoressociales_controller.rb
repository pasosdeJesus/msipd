# encoding: UTF-8

require 'bcrypt'

require 'sip/concerns/controllers/actoressociales_controller'
require 'sipd/concerns/controllers/sipd_controller'

module Sipd
  module Concerns
    module Controllers
      module ActoressocialesController

        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Controllers::ActoressocialesController
          include Sipd::Concerns::Controllers::SipdController

          def atributos_show
            [ :id, 
              :dominio,
              :grupoper_id,
              { :sectoractor_ids => [] },
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
          # un actor social con un dominio, y si se valida
          # que no tenga dominios antes de eliminar no podría eliminar).
          def destroy(mens = "", verifica_tablas_union=true)
            super(mens, false)
          end

          def lista_params_sipd
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
            lista_params_sipd
          end

          # Lista blanca de paramétros
          def actorsocial_params
            params.require(:actorsocial).permit(lista_params)
          end

        end  # included

      end
    end
  end
end

