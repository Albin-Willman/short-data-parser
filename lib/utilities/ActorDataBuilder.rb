class ActorDataBuilder
  def run(actor)
    return unless actor.positions.any?
    {
      name: actor.name,
      key: actor.key,
      positions: build_actor_positions(actor)
    }
  end

  private

  def build_actor_positions(actor)
    actor.uniq_companies.inject({}) do |s, e|
      s[e.key] = {
        name: e.name,
        key: e.key,
        positions: build_company_positions(actor, e)
      }
      s
    end
  end

  def build_company_positions(actor, company)
    positions = company.actor_positions(actor).order('date ASC').to_a
    current = Position.new(value: 0.0)

    date_range(actor).inject({}) do |s, e|
      if positions.first && positions.first[:date] <= e
        current = positions.shift
      end
      s[e.to_s] = current.value
      s
    end
  end

  def date_range(actor)
    (actor.first_position_date..Date.today)
  end
end
