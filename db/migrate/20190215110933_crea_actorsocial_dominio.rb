# encoding: UTF-8

class CreaActorsocialDominio < ActiveRecord::Migration[5.2]
  def up
    create_join_table :sip_actorsocial, :sipd_dominio, {
      table_name: 'sipd_actorsocial_dominio'
    }
    add_foreign_key :sipd_actorsocial_dominio, :sipd_dominio
    add_foreign_key :sipd_actorsocial_dominio, :sip_actorsocial
    rename_column :sipd_actorsocial_dominio, :sipd_dominio_id, :dominio_id
    rename_column :sipd_actorsocial_dominio, :sip_actorsocial_id, 
      :actorsocial_id

    execute <<-SQL
      INSERT INTO sipd_actorsocial_dominio (actorsocial_id, dominio_id)
        (SELECT id, dominio_id FROM sip_actorsocial 
        WHERE dominio_id IS NOT NULL);
    SQL
    remove_column :sip_actorsocial, :dominio_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
