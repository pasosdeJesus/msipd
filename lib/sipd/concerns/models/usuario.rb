# encoding: UTF-8

require 'sip/concerns/models/usuario'

module Sipd
  module Concerns
    module Models
      module Usuario
        extend ActiveSupport::Concern

        included do
          include Sip::Concerns::Models::Usuario

          belongs_to :dominio, class_name: 'Sipd::Dominio', validate: true

          scope :filtro_dominio_id, lambda {|d|
            where(dominio_id: d)
          }

        end

      end
    end
  end
end

