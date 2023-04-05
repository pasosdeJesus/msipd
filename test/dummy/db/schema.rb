# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_11_104537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "msip_actorsocial", force: :cascade do |t|
    t.integer "grupoper_id", null: false
    t.string "telefono", limit: 500
    t.string "fax", limit: 500
    t.string "direccion", limit: 500
    t.integer "pais_id"
    t.string "web", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grupoper_id"], name: "index_msip_actorsocial_on_grupoper_id"
    t.index ["pais_id"], name: "index_msip_actorsocial_on_pais_id"
  end

  create_table "msip_actorsocial_persona", force: :cascade do |t|
    t.integer "persona_id", null: false
    t.integer "actorsocial_id"
    t.integer "perfilactorsocial_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "msip_actorsocial_sectoractor", id: false, force: :cascade do |t|
    t.integer "actorsocial_id"
    t.integer "sectoractor_id"
  end

  create_table "msip_anexo", id: :serial, force: :cascade do |t|
    t.date "fecha", null: false
    t.string "descripcion", limit: 1500, null: false, collation: "es_co_utf_8"
    t.string "archivo", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "adjunto_file_name", limit: 255
    t.string "adjunto_content_type", limit: 255
    t.integer "adjunto_file_size"
    t.datetime "adjunto_updated_at"
  end

  create_table "msip_clase", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.integer "municipio_id", null: false
    t.integer "clalocal_cod"
    t.string "tclase_id", limit: 10, default: "CP", null: false
    t.float "latitud"
    t.float "longitud"
    t.date "fechacreacion", null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
  end

  create_table "msip_departamento", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.integer "pais_id", null: false
    t.integer "deplocal_cod"
    t.float "latitud"
    t.float "longitud"
    t.date "fechacreacion", default: -> { "('now'::text)::date" }, null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
    t.index ["id"], name: "msip_departamento_id_key", unique: true
    t.index ["pais_id", "deplocal_cod"], name: "msip_departamento_pais_id_deplocal_cod_key", unique: true
  end

  create_table "msip_etiqueta", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
    t.date "fechacreacion", default: -> { "('now'::text)::date" }, null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "msip_fuenteprensa", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, collation: "es_co_utf_8"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
    t.date "fechacreacion"
    t.date "fechadeshabilitacion"
    t.datetime "created_at", null: false
    t.datetime "updated_at"
  end

  create_table "msip_grupo", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.string "observaciones", limit: 5000
    t.date "fechacreacion", null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "msip_grupo_usuario", id: false, force: :cascade do |t|
    t.integer "usuario_id", null: false
    t.integer "mgrupo_id", null: false
  end

  create_table "msip_grupoper", comment: "Creado por msip en sipdes_des", force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.string "anotaciones", limit: 1000
  end

  create_table "msip_municipio", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.integer "departamento_id", null: false
    t.integer "munlocal_cod"
    t.float "latitud"
    t.float "longitud"
    t.date "fechacreacion", default: -> { "('now'::text)::date" }, null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
  end

  create_table "msip_oficina", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.date "fechacreacion", default: -> { "('now'::text)::date" }, null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
  end

  create_table "msip_pais", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 200, collation: "es_co_utf_8"
    t.string "nombreiso", limit: 200
    t.float "latitud"
    t.float "longitud"
    t.string "alfa2", limit: 2
    t.string "alfa3", limit: 3
    t.integer "codiso"
    t.string "div1", limit: 100
    t.string "div2", limit: 100
    t.string "div3", limit: 100
    t.date "fechacreacion"
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
  end

  create_table "msip_perfilactorsocial", force: :cascade do |t|
    t.string "nombre", limit: 500, null: false
    t.string "observaciones", limit: 5000
    t.date "fechacreacion", null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "msip_persona", id: :serial, force: :cascade do |t|
    t.string "nombres", limit: 100, null: false, collation: "es_co_utf_8"
    t.string "apellidos", limit: 100, null: false, collation: "es_co_utf_8"
    t.integer "anionac"
    t.integer "mesnac"
    t.integer "dianac"
    t.string "sexo", limit: 1, null: false
    t.integer "departamento_id"
    t.integer "municipio_id"
    t.integer "clase_id"
    t.string "numerodocumento", limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "pais_id"
    t.integer "nacionalde"
    t.integer "tdocumento_id"
  end

  create_table "msip_persona_trelacion", id: :serial, force: :cascade do |t|
    t.integer "persona1", null: false
    t.integer "persona2", null: false
    t.string "trelacion_id", limit: 2, default: "SI", null: false
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["id"], name: "msip_persona_trelacion_id_key", unique: true
    t.index ["persona1", "persona2", "trelacion_id"], name: "msip_persona_trelacion_persona1_persona2_trelacion_id_key", unique: true
    t.index ["persona1", "persona2", "trelacion_id"], name: "msip_persona_trelacion_persona1_persona2_trelacion_id_key1", unique: true
  end

  create_table "msip_sectoractor", force: :cascade do |t|
    t.string "nombre", limit: 500, null: false
    t.string "observaciones", limit: 5000
    t.date "fechacreacion", null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "msip_tclase", id: :string, limit: 10, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.date "fechacreacion", null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
  end

  create_table "msip_tdocumento", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.string "sigla", limit: 100
    t.string "formatoregex", limit: 500
    t.date "fechacreacion", null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
  end

  create_table "msip_trelacion", id: :string, limit: 2, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
    t.date "fechacreacion", null: false
    t.date "fechadeshabilitacion"
    t.string "inverso", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "msip_tsitio", id: :serial, force: :cascade do |t|
    t.string "nombre", limit: 500, null: false, collation: "es_co_utf_8"
    t.date "fechacreacion", default: -> { "('now'::text)::date" }, null: false
    t.date "fechadeshabilitacion"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "observaciones", limit: 5000, collation: "es_co_utf_8"
  end

  create_table "msip_ubicacion", id: :serial, force: :cascade do |t|
    t.string "lugar", limit: 500, collation: "es_co_utf_8"
    t.string "sitio", limit: 500, collation: "es_co_utf_8"
    t.integer "clase_id"
    t.integer "municipio_id"
    t.integer "departamento_id"
    t.integer "tsitio_id", default: 1, null: false
    t.float "latitud"
    t.float "longitud"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "pais_id"
  end

  create_table "usuario", id: :serial, force: :cascade do |t|
    t.string "nusuario", limit: 15, null: false
    t.string "password", limit: 64, default: "", null: false
    t.string "descripcion", limit: 50
    t.integer "rol", default: 4
    t.string "idioma", limit: 6, default: "es_CO", null: false
    t.date "fechacreacion", default: -> { "('now'::text)::date" }, null: false
    t.date "fechadeshabilitacion"
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.integer "failed_attempts"
    t.string "unlock_token", limit: 64
    t.datetime "locked_at"
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "regionsjr_id"
    t.string "nombre", limit: 50, collation: "es_co_utf_8"
    t.index ["email"], name: "index_usuario_on_email", unique: true
  end

  add_foreign_key "msip_actorsocial", "msip_grupoper", column: "grupoper_id"
  add_foreign_key "msip_actorsocial", "msip_pais", column: "pais_id"
  add_foreign_key "msip_actorsocial_persona", "msip_actorsocial", column: "actorsocial_id"
  add_foreign_key "msip_actorsocial_persona", "msip_persona", column: "persona_id"
  add_foreign_key "msip_actorsocial_sectoractor", "msip_actorsocial", column: "actorsocial_id"
  add_foreign_key "msip_actorsocial_sectoractor", "msip_sectoractor", column: "sectoractor_id"
  add_foreign_key "msip_clase", "msip_municipio", column: "municipio_id", name: "clase_municipio_id_fkey"
  add_foreign_key "msip_clase", "msip_tclase", column: "tclase_id", name: "clase_tclase_id_fkey"
  add_foreign_key "msip_departamento", "msip_pais", column: "pais_id", name: "departamento_pais_id_fkey"
  add_foreign_key "msip_grupo_usuario", "msip_grupo"
  add_foreign_key "msip_grupo_usuario", "usuario"
  add_foreign_key "msip_municipio", "msip_departamento", column: "departamento_id", name: "msip_municipio_departamento_id_fkey"
  add_foreign_key "msip_persona", "msip_clase", column: "clase_id", name: "persona_clase_id_fkey"
  add_foreign_key "msip_persona", "msip_municipio", column: "municipio_id", name: "persona_municipio_id_fkey"
  add_foreign_key "msip_persona", "msip_pais", column: "pais_id", name: "persona_pais_id_fkey"
  add_foreign_key "msip_persona", "msip_pais", column: "nacionalde", name: "persona_nacionalde_fkey"
  add_foreign_key "msip_persona", "msip_tdocumento", column: "tdocumento_id", name: "persona_tdocumento_id_fkey"
  add_foreign_key "msip_persona_trelacion", "msip_persona", column: "persona1", name: "persona_trelacion_persona1_fkey"
  add_foreign_key "msip_persona_trelacion", "msip_persona", column: "persona2", name: "persona_trelacion_persona2_fkey"
  add_foreign_key "msip_persona_trelacion", "msip_trelacion", column: "trelacion_id", name: "persona_trelacion_trelacion_id_fkey"
  add_foreign_key "msip_ubicacion", "msip_clase", column: "clase_id", name: "ubicacion_clase_id_fkey"
  add_foreign_key "msip_ubicacion", "msip_departamento", column: "departamento_id", name: "ubicacion_departamento_id_fkey"
  add_foreign_key "msip_ubicacion", "msip_municipio", column: "municipio_id", name: "ubicacion_municipio_id_fkey"
  add_foreign_key "msip_ubicacion", "msip_pais", column: "pais_id", name: "ubicacion_pais_id_fkey"
  add_foreign_key "msip_ubicacion", "msip_tsitio", column: "tsitio_id", name: "ubicacion_tsitio_id_fkey"
end
