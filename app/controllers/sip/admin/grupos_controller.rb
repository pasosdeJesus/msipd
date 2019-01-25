# encoding: UTF-8

require 'sipd/concerns/controllers/grupos_controller'
module Sip
  module Admin
    class GruposController < Sip::Admin::BasicasController

      include Sipd::Concerns::Controllers::GruposController
      load_and_authorize_resource class: Sip::Grupo

    end
  end
end

