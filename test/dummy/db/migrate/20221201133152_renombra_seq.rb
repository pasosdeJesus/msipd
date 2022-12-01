class RenombraSeq < ActiveRecord::Migration[7.0]
  include Msip::SqlHelper

  def change
    renombrar_secuencia_pg "sip_anexo_id_seq1", "msip_anexo_id_seq"
    renombrar_secuencia_pg "sip_clase_id_seq1", "msip_clase_id_seq"
    renombrar_secuencia_pg "sip_departamento_id_seq1", "msip_departamento_id_seq"
    renombrar_secuencia_pg "sip_municipio_id_seq1", "msip_municipio_id_seq"
    renombrar_secuencia_pg "sip_etiqueta_id_seq1", "msip_etiqueta_id_seq"
    renombrar_secuencia_pg "sip_oficina_id_seq1", "msip_oficina_id_seq"
    renombrar_secuencia_pg "sip_pais_id_seq1", "msip_pais_id_seq"
    renombrar_secuencia_pg "sip_persona_id_seq1", "msip_persona_id_seq"
    renombrar_secuencia_pg "sip_persona_trelacion_id_seq1", "msip_persona_trelacion_id_seq"
    renombrar_secuencia_pg "sip_tsitio_id_seq1", "msip_tsitio_id_seq"
    renombrar_secuencia_pg "sip_ubicacion_id_seq1", "msip_ubicacion_id_seq"
  end
end
