require 'bcrypt'

require 'sip/concerns/controllers/personas_controller'
require 'sipd/concerns/controllers/sipd_controller'

module Sipd
  module Concerns
    module Controllers
      module PersonasController

        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Controllers::PersonasController
          include Sipd::Concerns::Controllers::SipdController

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
              :clase,
              :nacionalde,
              :tdocumento,
              :numerodocumento
            ]
          end

          def lista_params_sipd
            r = atributos_form - [:dominio] +
              [ :dominio_ids => [] ]
            return r
          end

          def lista_params
            lista_params_sipd
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

