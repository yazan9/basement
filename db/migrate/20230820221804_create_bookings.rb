class CreateBookings < ActiveRecord::Migration[6.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :provider, null: false, references: :users

      t.integer :frequency, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.datetime :start_at, null: false
      t.decimal :rate, precision: 5, scale: 2, default: 0.0, null: false
      t.text :comments

      t.timestamps
    end

    add_foreign_key :bookings, :users, column: :provider_id
  end
end
