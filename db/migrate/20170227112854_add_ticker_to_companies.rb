class AddTickerToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :ticker, :string
  end
end
