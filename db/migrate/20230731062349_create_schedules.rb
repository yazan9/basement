class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      t.references :order, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
