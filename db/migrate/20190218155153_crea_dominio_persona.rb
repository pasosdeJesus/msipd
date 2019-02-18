# encoding: UTF-8

class CreaDominioPersona < ActiveRecord::Migration[5.2]

  def up
    create_join_table :sipd_dominio, :sip_persona, {
      table_name: 'sipd_dominio_persona'
    }
    add_foreign_key :sipd_dominio_persona, :sipd_dominio
    add_foreign_key :sipd_dominio_persona, :sip_persona
    rename_column :sipd_dominio_persona, :sipd_dominio_id, :dominio_id
    rename_column :sipd_dominio_persona, :sip_persona_id, :persona_id

    execute <<-SQL
      INSERT INTO sipd_dominio_persona (persona_id, dominio_id)
        (SELECT id, dominio_id FROM sip_persona 
        WHERE dominio_id IS NOT NULL);
    SQL
    remove_column :sip_persona, :dominio_id
  end

  def down
    #drop_table :sipd_dominio_persona
    raise ActiveRecord::IrreversibleMigration
  end
end
