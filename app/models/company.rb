class Company < ApplicationRecord
  has_many :positions
  has_many :blog_posts
  has_many :actors, through: :positions
  validates_presence_of :name, :key
  validates_uniqueness_of :key

  def total
    @total ||= compute_total
  end

  def last_change
    @last_change ||= find_last_change
  end

  def last_registred_change
    @last_registred_change ||= find_last_registred_change
  end

  def change_30_days
    @change_30_days ||= compute_change_30_days
  end

  def uniq_actors
    @uniq_actors ||= actors.distinct
  end

  def first_position_date
    @first_position_date ||= find_first_change
  end

  def actor_positions(actor)
    positions.where(actor_id: actor.id)
  end

  private

  def compute_total
    uniq_actors.inject(0) { |sum, actor| sum + actor.current_position(self) }
  end

  def find_last_change
    positions.order('positions.date DESC').limit(1).first.date
  end

  def find_last_registred_change
    positions.order('positions.date DESC').limit(1).first.created_at
  end

  def find_first_change
    positions.order('positions.date ASC').limit(1).first.date
  end

  def compute_change_30_days
    thirty_days_ago = Date.today - 30.days
    total_30_days_ago = uniq_actors.inject(0) { |sum, actor| sum + actor.position_at(self, thirty_days_ago) }

    total - total_30_days_ago
  end
end
