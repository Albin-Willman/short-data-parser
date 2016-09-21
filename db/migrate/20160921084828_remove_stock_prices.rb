class RemoveStockPrices < ActiveRecord::Migration[5.0]
  def up
    drop_table :stock_prices
  end

  def down
    create_table :stock_prices do |t|
      t.float :high
      t.float :low
      t.float :close
      t.date :date
      t.belongs_to :company, foreign_key: true

      t.timestamps
    end
  end
end
