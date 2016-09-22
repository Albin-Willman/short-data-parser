class ActorIndexBuilder
  def run
    {
      actors: Actor.all.inject([]) { |data, a| build_actor_data(data, a) },
      lastChange: Date.today.to_s
    }
  end

  def build_actor_data(list, actor)
    list << {
      name: actor.name,
      noOfActivePositions: count_active_investments(actor),
      lastChange: actor.last_registred_change
    }
    list
  end

  def count_active_investments(actor)
    actor.uniq_companies.inject(0) do |sum, c|
      sum += 1 if actor.current_position(c) > 0
      sum
    end
  end
end