class CompanyChecker

  def check_company(company, data, file_path)
    puts "**** #{company} ****"

    nn_id = data['nn_id']
    return unless nn_id && nn_id != '-'

    relevant_dates = DateList.new.run(company, file_path)
    relevant_dates.uniq!
    historic_dates = fetch_historic_data(company)

    nn_data = {}
    relevant_dates.each do |date|
      unless historic_dates.include?(date)
        nn_data = fetch_nn_data(nn_id) if nn_id
        if nn_data[date]
          puts "Filling #{date} with #{nn_data[date]}"
          fill_date(company, nn_data[date], date)
        else
          puts "No data for: #{date}"
        end
      end
    end
  end

  def fetch_nn_data(nn_id)
    return {} unless nn_id && nn_id.length > 0
    url = "https://www.nordnet.se/graph/instrument/11/#{nn_id}?from=2012-11-01&to=#{Date.today}&fields=last,high,low"
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
    rescue
      puts 'exception'
      return {}
    end
  end

  def fill_date(company, date_data, date)
    stock_path = build_stock_path(company)

    data = get_old_stock_data(company)
    data['history'][date.to_s] = {
      high: date_data[:high].to_f,
      low: date_data[:low].to_f
    }
    data['last'] = data[:close]
    File.open(stock_path, "w") do |f|
      f.write(data.to_json)
    end
  end

  def get_old_stock_data(company)
    stock_path = build_stock_path(company)
    return {'history' => {}, 'last' => 0.0} unless Pathname.new(stock_path).exist?
    JSON.parse(File.read(stock_path))
  end

  def build_stock_path(company)
    "data/dist/api/stocks/#{company}.json"
  end

  def fetch_historic_data(company)
    get_old_stock_data(company)['history'].keys
  end
end
