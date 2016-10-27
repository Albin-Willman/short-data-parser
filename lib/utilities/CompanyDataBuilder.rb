class CompanyDataBuilder

  def run(company)
    return unless company.positions.any?
    {
      history: build_company_history(company),
      positions: build_company_positions(company),
    }
  end

  private

  def build_company_history(company)

    prices = fetch_nn_data(company.nn_id, company.first_position_date)
    return {} if prices.nil? || prices.length == 0
    current = prices.shift

    date_range(company).inject({}) do |s, e|
      current = prices.shift if prices.first && prices.first[:date] <= e
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
      if positions.first && positions.first[:date] <= e
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
      high: sp[:high],
      low: sp[:low],
      close: sp[:close]
    }
  end

  def fetch_nn_data(nn_id, first_date)
    return [] unless nn_id && nn_id != '-' && nn_id.length > 0
    url = "https://www.nordnet.se/graph/instrument/11/#{nn_id}?from=#{first_date}&to=#{Date.today}&fields=last,high,low"
    begin
      historic_data = JSON.parse(open(url).read)
      return historic_data.inject([]) do |res, day_data|
        date = Time.at(day_data['time']/1000).to_date
        res << {
          high: day_data['high'],
          low: day_data['low'],
          close: day_data['last'],
          date: date
        }
        res.sort_by do |item|
          item[:date]
        end
      end
    # rescue
    #   puts 'exception'
    #   return {}
    end
  end
end