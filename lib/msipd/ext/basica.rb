require 'msip/basica'

module Msipd
  module Ext
    module Basica

      def verifica_msipd
        return true
      end

      belongs_to :dominio, class_name: 'Msipd::Dominio', validate: true, 
        optional: false

      scope :filtro_dominio_id, lambda {|d|
        where(dominio_id: d)
      }

    end
  end
end


#Msip::Basica.class_eval do
#  prepend Msipd::Ext::Basica
#end
