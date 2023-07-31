class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true  # Add the foreign key referencing the users table
      t.integer :hours
      t.integer :frequency
      t.decimal :price
      t.integer :status

      t.timestamps
    end
  end
end
