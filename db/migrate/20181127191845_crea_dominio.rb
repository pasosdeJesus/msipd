class CreaDominio < ActiveRecord::Migration[5.2]
  def up
    create_table :sipd_dominio do |t|
      t.string :dominio, limit: 500, null: false
      t.string :mandato, limit: 5000, null: false

      t.timestamps null: false
    end
    execute <<-SQL
      INSERT INTO sipd_dominio (id, dominio, mandato, created_at, updated_at)
        VALUES (1, 'sipd.pasosdeJesus.org', 
          'Tecnología con misión. Remplazar con mandato de la organización',
          '2018-11-27', '2018-11-27');
    SQL
  end
  def down
    drop_table :sipd_dominio
  end
end
