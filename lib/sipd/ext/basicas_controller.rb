require 'msip/admin/basicas_controller'

module Sipd
  module Ext
    module BasicasController 

      def verifica_sipd
        return true
      end
       
      def atributos_index
        r = ["id"]
        if can? :manage, Sipd::Dominio
          r << "dominio_id"
        end
        r += [
          "nombre", 
          "observaciones", 
          "fechacreacion_localizada", 
          "habilitado"
        ]
        return r
      end
    end
  end
end



Msip::Admin::BasicasController.class_eval do
      include NavbarHelper
      helper NavbarHelper
  prepend Sipd::Ext::BasicasController
end
