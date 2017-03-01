require 'twitter'
require_relative "../utilities/ChartGenerator.rb"

class Tweeter
  def self.send_tweet(company, data)
    file_name = ChartGenerator.build_company_chart(company.name, data)
    begin
      client.update_with_media(company_tweet_text(company), File.new(file_name))
    rescue
      client.update(company_tweet_text(company))
    end
  end

  def self.send_summary(companies)
    tickers = fetch_tickers(companies)
    client.update(summary_tweet_text(tickers))
  end

  def self.send_test_tweet
    client.update('Test tweet')
  end

  def self.fetch_tickers(companies)
    companies.map(&:ticker).reject(&:blank?).map {|t| "$#{t}"}
  end

  def self.summary_tweet_text(tickers)
    return "Todays short changes: #{tickers.join(', ')} http://kortapositioner.se/stocks #blankning"  if tickers.length > 0
    'No changes in todays update. http://kortapositioner.se/stocks #blankning'
  end

  def self.company_tweet_text(company)
    "Changes in #{ticker(company)}. Total short: #{company.total.round(2)}\% http://kortapositioner.se/stock/#{company.key} #blankning#{company.ticker ? " \##{company.ticker}" : ''}"
  end

  def self.ticker(company)
    company.ticker ? "$#{company.ticker.upcase}" : company.name.strip
  end

  def self.client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end
end
