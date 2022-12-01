Msip::Perfilorgsocial.class_eval  do
    def verifica_sipd
      return true
    end

    belongs_to :dominio, class_name: 'Sipd::Dominio', validate: true, 
      optional: false

    scope :filtro_dominio_id, lambda {|d|
      where(dominio_id: d)
    }

end

