class Actor < ApplicationRecord
  has_many :positions
  validates_presence_of :name, :key
  validates_uniqueness_of :key

  def current_position(company)
    position_at(company, Date.today)
  end

  def position_at(company, date)
    postion = positions.where("company_id = ? AND date <= ?", company.id, date).order('positions.date DESC').limit(1).first
    postion.is_a?(Position) ? postion.value : 0.0
  end

  def company_positions(company)
    positions.where(company_id: company.id)
  end
end
