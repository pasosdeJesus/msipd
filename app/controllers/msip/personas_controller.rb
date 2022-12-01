require 'sipd/concerns/controllers/personas_controller'

module Msip
  class PersonasController < Msip::ModelosController

    include Sipd::Concerns::Controllers::PersonasController
    #load_and_authorize_resource class: Msip::Grupo
    # No autorizamos aquí porque la autorización es más
    # detallada en las funcines de modelos_controller

  end
end

