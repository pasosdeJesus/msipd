class DominioGrupoNN < ActiveRecord::Migration[5.2]
  def up
    create_join_table :sipd_dominio, :sip_grupo, {
      table_name: 'sipd_dominio_grupo'
    }
    add_foreign_key :sipd_dominio_grupo, :sipd_dominio
    add_foreign_key :sipd_dominio_grupo, :sip_grupo
    rename_column :sipd_dominio_grupo, :sipd_dominio_id, :dominio_id
    rename_column :sipd_dominio_grupo, :sip_grupo_id, :grupo_id

    execute <<-SQL
      INSERT INTO sipd_dominio_grupo (dominio_id, grupo_id)
        (SELECT dominio_id, id FROM sip_grupo WHERE dominio_id IS NOT NULL);
    SQL
    remove_column :sip_grupo, :dominio_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
