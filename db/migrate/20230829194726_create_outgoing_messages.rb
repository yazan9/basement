class CreateOutgoingMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :outgoing_messages do |t|
      t.integer :message_type
      t.integer :status
      t.text :content
      t.jsonb :data
      t.string :error_message
      t.integer :platform
      t.string :to

      t.timestamps
    end
  end
end
