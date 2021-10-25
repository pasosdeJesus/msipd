require 'sipd/concerns/controllers/actoressociales_controller'
module Sip
  class ActoressocialesController < Sip::ModelosController

    include Sipd::Concerns::Controllers::ActoressocialesController
    #load_and_authorize_resource class: Sip::Grupo
    # No autorizamos aquí porque la autorización es más
    # detallada en las funcines de modelos_controller

  end
end

