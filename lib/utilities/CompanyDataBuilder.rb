class CompanyDataBuilder

  def run(company)
    {
      history: build_company_history(company),
      positions: build_company_positions(company),
    }
  end

  private

  def build_company_history(company)
    prices = company.stock_prices.to_a
    return {} if prices.length == 0
    current = prices.shift

    date_range(company).inject({}) do |s, e|
      current = prices.shift if prices.first && prices.first.date <= e
      s[e.to_s] = build_price_data(current)
      s
    end
  end

  def build_company_positions(company)
    company.uniq_actors.inject({}) do |s, e|
      s[e.key] = {
        name: e.name,
        key: e.key,
        positions: build_actor_positions(e, company)
      }
      s
    end
  end

  def build_actor_positions(actor, company)
    positions = actor.company_positions(company).order('date ASC').to_a
    current = Position.new(value: 0.0)

    date_range(company).inject({}) do |s, e|
      if positions.first && positions.first.date <= e
        current = positions.shift
      end
      s[e.to_s] = current.value
      s
    end
  end

  def date_range(company)
    (company.first_position_date..Date.today)
  end

  def build_price_data(sp)
    {
      high: sp.high,
      low: sp.low,
      close: sp.close
    }
  end
end