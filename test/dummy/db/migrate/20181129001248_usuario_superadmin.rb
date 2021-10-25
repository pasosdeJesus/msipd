class UsuarioSuperadmin < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    -- usuario sipd clave sipd
      INSERT INTO usuario (nusuario, email, encrypted_password, password, 
        fechacreacion, created_at, updated_at, rol) 
      VALUES ('sipd', 'sipd@localhost', 
        '$2a$10$uPICXBx8K/csSb5q3uNsPOwuU1h.9O5Kj9dyQbaCy8gF.5rrPJgG.',
        '', '2018-11-28', '2018-11-28', '2018-11-28', 1);
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM usuario WHERE nusuario='sipd';
    SQL
  end
end
