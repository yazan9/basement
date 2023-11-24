class CreateConversations < ActiveRecord::Migration[6.1]
  def change
    create_table :conversations do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.boolean :archived, default: false

      t.timestamps
    end
    # Indexes are automatically created for foreign key references
  end
end
