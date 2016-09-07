require 'open-uri'
require "net/http"
class Downloader

  def run(file_path, date)
    url = build_url(date)
    unless valid_url?(url)
      url = build_url(date + '_NY')
      raise 'No file to download' unless valid_url?(url)
    end
    open(file_path, 'wb') do |file|
      file << open(build_url(date)).read
    end
    file_path
  end

  private

  def valid_url?(url)
    uri = URI.parse(url)
    req = Net::HTTP.new(uri.host, uri.port)
    res = req.request_head(uri.path)
    res.code == "200"
  end

  def build_url(date)
    "http://www.fi.se/upload/50_Marknadsinfo/Blankning/Korta_positioner_#{date}.xls"
  end
end

