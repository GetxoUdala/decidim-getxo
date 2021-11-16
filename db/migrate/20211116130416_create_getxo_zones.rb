class CreateGetxoZones < ActiveRecord::Migration[5.2]
  def change
    create_table :getxo_zones do |t|
      t.integer :decidim_organization_id, foreign_key: true
      t.string :name, null: false
      t.references :street, foreign_key: true, index: true, foreign_key: { to_table: :getxo_streets }
      t.integer :numbers_constraint, null: false, default: 0 # all, odd, even
      t.string :numbers_range, null: false, default: "" # series constraint: 1,2,3 or 1-30
      t.timestamps
    end
  end
end
