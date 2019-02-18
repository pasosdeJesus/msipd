# encoding: UTF-8

require 'sipd/concerns/controllers/personas_controller'

module Sip
  class PersonasController < Sip::ModelosController

    include Sipd::Concerns::Controllers::PersonasController
    #load_and_authorize_resource class: Sip::Grupo
    # No autorizamos aquí porque la autorización es más
    # detallada en las funcines de modelos_controller

  end
end

