class AddHoursToBookings < ActiveRecord::Migration[6.1]
  def change
    add_column :bookings, :hours, :integer, default: 0
  end
end
