# encoding: UTF-8
require_dependency "sipd/concerns/controllers/dominios_controller"

module Sipd
  class DominiosController < Sip::ModelosController
    include Sipd::Concerns::Controllers::DominiosController
  end
end
