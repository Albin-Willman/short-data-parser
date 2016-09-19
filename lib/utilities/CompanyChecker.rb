class CompanyChecker

  def check_company(company)
    puts "**** #{company.name} ****"

    nn_id = company.nn_id
    return unless nn_id && nn_id != '-'

    first_date = company.positions.order('positions.date ASC').limit(1).first.date
    historic_dates = company.stock_prices.map(&:date).map(&:to_s)

    nn_data = fetch_nn_data(nn_id, first_date)
    previous = nil
    (first_date..Date.yesterday).each do |date|
      date_string = date.to_s
      unless historic_dates.include?(date_string)
        if nn_data[date_string]
          puts "Filling #{date_string} with #{nn_data[date_string]}"
          previous = StockPrice.create(
              high: nn_data[date_string][:high],
              low: nn_data[date_string][:low],
              close: nn_data[date_string][:close],
              date: date,
              company: company
            )
        else
          previous = StockPrice.create(
              high: previous.high,
              low: previous.low,
              close: previous.close,
              date: date,
              company: company
            ) if previous
        end
      end
    end
  end

  def fetch_nn_data(nn_id, first_date)
    return {} unless nn_id && nn_id.length > 0
    url = "https://www.nordnet.se/graph/instrument/11/#{nn_id}?from=#{first_date}&to=#{Date.today}&fields=last,high,low"
    begin
      historic_data = JSON.parse(open(url).read)
      return historic_data.inject({}) do |res, day_data|
        date = Time.at(day_data['time']/1000).to_date.to_s
        res[date] = {
          high: day_data['high'],
          low: day_data['low'],
          close: day_data['last']
        }
        res
      end
    # rescue
    #   puts 'exception'
    #   return {}
    end
  end
end
