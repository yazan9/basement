class CreateBookingSlots < ActiveRecord::Migration[6.1]
  def change
    create_table :booking_slots do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end

    add_index :booking_slots, :start_at
    add_index :booking_slots, :end_at
  end
end
