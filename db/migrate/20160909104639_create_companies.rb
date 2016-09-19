class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.string :nn_id
      t.string :name
      t.string :key

      t.timestamps
    end
  end
end
