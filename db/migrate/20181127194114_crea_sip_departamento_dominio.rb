class CreaSipDepartamentoDominio < ActiveRecord::Migration[5.2]
  def change
    create_join_table :sip_departamento, :sipd_dominio, 
      table_name: :sipd_departamento_dominio
    add_foreign_key :sipd_departamento_dominio, :sipd_dominio
    add_foreign_key :sipd_departamento_dominio, :sip_departamento
    rename_column :sipd_departamento_dominio, :sipd_dominio_id, :dominio_id
    rename_column :sipd_departamento_dominio, :sip_departamento_id, :departamento_id
  end
end
