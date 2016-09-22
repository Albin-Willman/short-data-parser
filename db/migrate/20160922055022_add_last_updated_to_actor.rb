class AddLastUpdatedToActor < ActiveRecord::Migration[5.0]
  def change
    add_column :actors, :last_update, :date
  end
end
