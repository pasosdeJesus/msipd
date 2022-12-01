require 'msip/basica'

module Sipd
  module Ext
    module Basica

      def verifica_sipd
        return true
      end

      belongs_to :dominio, class_name: 'Sipd::Dominio', validate: true, 
        optional: false

      scope :filtro_dominio_id, lambda {|d|
        where(dominio_id: d)
      }

    end
  end
end


#Msip::Basica.class_eval do
#  prepend Sipd::Ext::Basica
#end
