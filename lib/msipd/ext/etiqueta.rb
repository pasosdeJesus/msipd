Msip::Etiqueta.class_eval  do
    def verifica_msipd
      return true
    end

    belongs_to :dominio, class_name: 'Msipd::Dominio', validate: true, 
      optional: false

    scope :filtro_dominio_id, lambda {|d|
      where(dominio_id: d)
    }

end

