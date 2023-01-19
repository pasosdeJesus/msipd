require 'msipd/concerns/controllers/dominios_controller'

module Msipd
  class DominiosController < Msip::ModelosController
    include Msipd::Concerns::Controllers::DominiosController
  end
end
