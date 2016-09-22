class ActorDataBuilder
  def run(actor)
    return if !actor.last_update.nil? && actor.last_update > actor.last_registred_change

    { positions: build_actor_positions(actor) }
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
