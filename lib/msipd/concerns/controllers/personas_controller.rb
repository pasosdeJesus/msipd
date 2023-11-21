require 'bcrypt'

require 'msip/concerns/controllers/personas_controller'
require 'msipd/concerns/controllers/msipd_controller'

module Msipd
  module Concerns
    module Controllers
      module PersonasController

        extend ActiveSupport::Concern

        included do
          include Msip::Concerns::Controllers::PersonasController
          include Msipd::Concerns::Controllers::SipdController

          def atributos_show
            [ :id, 
              :dominio,
              :nombres,
              :apellidos,
              :anionac,
              :mesnac,
              :dianac,
              :sexo,
              :pais,
              :departamento,
              :municipio,
              :centropoblado,
              :nacionalde,
              :tdocumento,
              :numerodocumento
            ]
          end

          def lista_params_msipd
            r = atributos_form - [:dominio] +
              [ :dominio_ids => [] ]
            return r
          end

          def lista_params
            lista_params_msipd
          end

          # Lista blanca de paramétros
          def persona_params
            params.require(:persona).permit(lista_params)
          end

        end  # included

      end
    end
  end
end

