class Actor < ApplicationRecord
  has_many :positions
  has_many :companies, through: :positions
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

  def first_position_date
    @first_position_date ||= find_first_change
  end

  def last_registred_change
    @last_registred_change ||= find_last_registred_change
  end

  def last_change
    @last_change ||= find_last_change
  end

  def uniq_companies
    @uniq_companies ||= companies.distinct
  end

  private

  def find_last_change
    positions.order('positions.date DESC').limit(1).first.try(:date)
  end

  def find_first_change
    positions.order('positions.date ASC').limit(1).first.try(:date)
  end

  def find_last_registred_change
    positions.order('positions.date DESC').limit(1).first.try(:created_at)
  end
end
