class CreateSystemEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :system_events do |t|
      t.string :title
      t.integer :event_type
      t.string :data

      t.timestamps
    end
  end
end
