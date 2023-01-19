require 'msip/admin/basicas_controller'

module Msipd
  module Ext
    module BasicasController 

      def verifica_msipd
        return true
      end
       
      def atributos_index
        r = ["id"]
        if can? :manage, Msipd::Dominio
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
  prepend Msipd::Ext::BasicasController
end
