class CreateReviews < ActiveRecord::Migration[6.0] # You might have a different version number, adjust accordingly.
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reviewee, null: false, references: :users
      t.text :content
      t.decimal :rating, precision: 3, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_foreign_key :reviews, :users, column: :reviewee_id
  end
end

