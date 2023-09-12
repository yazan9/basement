class AddAddressVerifiedToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :address_verified, :boolean, default: false
  end
end
