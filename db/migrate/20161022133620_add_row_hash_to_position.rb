class AddRowHashToPosition < ActiveRecord::Migration[5.0]
  def change
    add_column :positions, :line_hash, :string
    add_index :positions, :line_hash
  end
end
