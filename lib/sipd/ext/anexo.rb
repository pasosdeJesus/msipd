# encoding: UTF-8

Sip::Anexo.class_eval  do
    def verifica_sipd
      return true
    end

    belongs_to :dominio, class_name: 'Sipd::Dominio', validate: true

    scope :filtro_dominio_id, lambda {|d|
      where(dominio_id: d)
    }

end

