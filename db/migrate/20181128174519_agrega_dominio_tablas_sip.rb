class AgregaDominioTablasSip < ActiveRecord::Migration[5.2]
  def change
    add_column :sip_anexo, :dominio_id, :integer, default: 1
    add_foreign_key :sip_anexo, :sipd_dominio, column: :dominio_id
    add_column :sip_etiqueta, :dominio_id, :integer, default: 1
    add_foreign_key :sip_etiqueta, :sipd_dominio, column: :dominio_id
    add_column :sip_fuenteprensa, :dominio_id, :integer, default: 1
    add_foreign_key :sip_fuenteprensa, :sipd_dominio, column: :dominio_id
    add_column :sip_grupo, :dominio_id, :integer, default: 1
    add_foreign_key :sip_grupo, :sipd_dominio, column: :dominio_id
    add_column :usuario, :dominio_id, :integer, default: 1
    add_foreign_key :usuario, :sipd_dominio, column: :dominio_id
    add_column :sip_oficina, :dominio_id, :integer, default: 1
    add_foreign_key :sip_oficina, :sipd_dominio, column: :dominio_id
    add_column :sip_persona, :dominio_id, :integer, default: 1
    add_foreign_key :sip_persona, :sipd_dominio, column: :dominio_id
    add_column :sip_perfilactorsocial, :dominio_id, :integer, default: 1
    add_foreign_key :sip_perfilactorsocial, :sipd_dominio, column: :dominio_id
    add_column :sip_actorsocial, :dominio_id, :integer, default: 1
    add_foreign_key :sip_actorsocial, :sipd_dominio, column: :dominio_id
    add_column :sip_sectoractor, :dominio_id, :integer, default: 1
    add_foreign_key :sip_sectoractor, :sipd_dominio, column: :dominio_id
    add_column :sip_grupoper, :dominio_id, :integer, default: 1
    add_foreign_key :sip_grupoper, :sipd_dominio, column: :dominio_id
  end
end
