class AjustaDominiosIniciales < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      UPDATE sip_etiqueta SET dominio_id=NULL WHERE id IN (3,4,9,10);
      UPDATE sip_fuenteprensa SET dominio_id=NULL WHERE (id>=1 and id<=19) or id in (24,36,39) or (id>=41 and id<=54);
      UPDATE sip_oficina SET dominio_id=NULL WHERE id=1;
      SELECT setval('sipd_dominio_id_seq', 100, true);
    SQL
  end
  def down
  end
end
