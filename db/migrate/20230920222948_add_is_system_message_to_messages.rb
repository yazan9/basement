class AddIsSystemMessageToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :is_system_message, :boolean, default: false
  end
end
