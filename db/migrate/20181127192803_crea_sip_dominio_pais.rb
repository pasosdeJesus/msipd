class CreaSipDominioPais < ActiveRecord::Migration[5.2]
  def change
    create_join_table :sipd_dominio, :sip_pais, table_name: :sipd_dominio_pais
    add_foreign_key :sipd_dominio_pais, :sipd_dominio
    add_foreign_key :sipd_dominio_pais, :sip_pais
    rename_column :sipd_dominio_pais, :sipd_dominio_id, :dominio_id
    # Si el siguiente falla puede ser por falta de la infleccion plural
    # pais->paises, que deberia cargar con sipd
    rename_column :sipd_dominio_pais, :sip_pais_id, :pais_id
  end
end
