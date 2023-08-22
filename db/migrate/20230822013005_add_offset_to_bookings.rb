class AddOffsetToBookings < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :offset, :integer, default: 0
  end
end
