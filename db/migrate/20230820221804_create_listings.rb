class CreateListings < ActiveRecord::Migration[6.1]
  def change
    create_table :listings do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.decimal :rate, precision: 5, scale: 2, default: 0.0, null: false
      t.text :title
      t.text :description
      t.text :address

      t.timestamps
    end
    add_column :listings, :location, :geography, limit: { srid: 4326, type: "point", geographic: true }
  end
end
