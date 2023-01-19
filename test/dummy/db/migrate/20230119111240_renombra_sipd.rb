class RenombraSipd < ActiveRecord::Migration[7.0]
  TABLAS=[
    ['sipd_dominio', 'msipd_dominio'],
    ['sipd_dominio_grupo', 'msipd_dominio_grupo'],
    ['sipd_dominio_operaen_departamento', 'msipd_dominio_operaen_departamento'],
    ['sipd_dominio_operaen_pais', 'msipd_dominio_operaen_pais'],
    ['sipd_dominio_orgsocial', 'msipd_dominio_orgsocial'],
    ['sipd_dominio_persona', 'msipd_dominio_persona'],
    ['sipd_dominio_usuario', 'msipd_dominio_usuario']
  ]

  def up
    TABLAS.each do |nomini, nomfin|
      if table_exists?(nomini)
        rename_table nomini, nomfin
      end
    end
  end

  def down
    TABLAS.each do |nomini, nomfin|
      if table_exists?(nomfin)
        rename_table nomfin, nomini
      end
    end
  end

end
