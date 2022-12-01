require 'sipd/concerns/controllers/grupos_controller'
module Msip
  module Admin
    class GruposController < Msip::Admin::BasicasController

      include Sipd::Concerns::Controllers::GruposController
      #load_and_authorize_resource class: Msip::Grupo
      # No autorizamos aquí porque la autorización es más
      # detallada en las funcines de modelos_controller

    end
  end
end

