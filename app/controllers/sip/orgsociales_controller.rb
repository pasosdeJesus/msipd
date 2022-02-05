require 'sipd/concerns/controllers/orgsociales_controller'
module Sip
  class OrgsocialesController < Sip::ModelosController

    include Sipd::Concerns::Controllers::OrgsocialesController
    #load_and_authorize_resource class: Sip::Grupo
    # No autorizamos aquí porque la autorización es más
    # detallada en las funcines de modelos_controller

  end
end

