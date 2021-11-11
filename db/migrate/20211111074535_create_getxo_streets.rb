# frozen_string_literal: true

class CreateGetxoStreets < ActiveRecord::Migration[5.2]
  def change
    create_table :getxo_streets do |t|
      t.integer :decidim_organization_id, foreign_key: true
      t.string :name, null: false, index: true
      t.timestamps
    end
  end
end
