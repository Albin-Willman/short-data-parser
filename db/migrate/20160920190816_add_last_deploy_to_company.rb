class AddLastDeployToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :last_update, :date
  end
end
