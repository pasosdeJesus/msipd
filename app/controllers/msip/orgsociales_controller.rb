require 'msipd/concerns/controllers/orgsociales_controller'
module Msip
  class OrgsocialesController < Msip::ModelosController

    include Msipd::Concerns::Controllers::OrgsocialesController
    #load_and_authorize_resource class: Msip::Grupo
    # No autorizamos aquí porque la autorización es más
    # detallada en las funcines de modelos_controller

  end
end

