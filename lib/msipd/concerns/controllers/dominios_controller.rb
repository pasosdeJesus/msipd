module Msipd
  module Concerns
    module Controllers
      module DominiosController
        extend ActiveSupport::Concern

        included do

          before_action :set_dominio, only: [:show, :edit, :update, :destroy]
          load_and_authorize_resource class: Msipd::Dominio
          Msip::Departamento.conf_presenta_nombre_con_origen = true

          def clase
            "Msipd::Dominio"
          end

          def genclase
            return 'M'
          end

          def atributos_index
            [ :id, 
              :dominio,
              :mandato,
              { :operaen_pais_ids => [] },
              { :operaen_departamento_ids => [] }
            ]
          end

          def atributos_show
            atributos_index
          end

          def atributos_form
            a = atributos_show - [:id]
            return a
          end

          def index(c = nil)
            if c == nil
              c = Msipd::Dominio.all
            end
            super(c)
          end

          def set_dominio
            @dominio = Msipd::Dominio.find(params[:id])
            @registro = @dominio
          end

          def lista_params
              atributos_form 
          end

          def dominio_params
            params.require(:dominio).permit(lista_params)
          end

        end #included

      end
    end
  end
end

