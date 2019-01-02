class RenombraRelaciones < ActiveRecord::Migration[5.2]
  def change
    rename_table :sipd_dominio_pais, :sipd_dominio_operaen_pais
    rename_table :sipd_departamento_dominio, :sipd_dominio_operaen_departamento
  end
end
