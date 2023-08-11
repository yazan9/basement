class AddLocationToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :location, :geography, limit: { srid: 4326, type: "point", geographic: true }
  end
end
