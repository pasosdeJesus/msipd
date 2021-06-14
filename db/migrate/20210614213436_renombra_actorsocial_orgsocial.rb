class RenombraActorsocialOrgsocial < ActiveRecord::Migration[6.1]
  def change
    rename_table :sipd_actorsocial_dominio, :sipd_dominio_orgsocial
    rename_column :sipd_dominio_orgsocial, :actorsocial_id, :orgsocial_id
  end
end
