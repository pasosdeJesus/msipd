class UsuariosDominiosNn < ActiveRecord::Migration[5.2]
  def up
    create_join_table :sipd_dominio, :usuario, {
      table_name: 'sipd_dominio_usuario'
    }
    add_foreign_key :sipd_dominio_usuario, :sipd_dominio
    add_foreign_key :sipd_dominio_usuario, :usuario
    rename_column :sipd_dominio_usuario, :sipd_dominio_id,
      :dominio_id
    execute <<-SQL
      INSERT INTO sipd_dominio_usuario (dominio_id, usuario_id) 
        (SELECT dominio_id, id FROM usuario
          WHERE dominio_id IS NOT NULL);
    SQL
    remove_column :usuario, :dominio_id
  end
  def down
    add_column :usuario, :dominio_id, :integer, default: 1
    add_foreign_key :usuario, :sipd_dominio, column: :dominio_id
    execute <<-SQL
      UPDATE usuario SET dominio_id=sipd_dominio_usuario.dominio_id
        FROM sipd_dominio_usuario WHERE usuario.id=usuario_id;
    SQL
    drop_table :sipd_dominio_usuario
  end
end
