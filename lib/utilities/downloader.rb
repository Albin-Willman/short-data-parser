require 'open-uri'
require "net/http"

POSSIBLE_FILES = [
  ['', 'xls'],
  ['_NY', 'xls'],
  ['test', 'xls'],
  ['', 'xlsx'],
  ['_NY', 'xlsx'],
  ['test', 'xlsx']
]

class Downloader

  def run(file_base, date)
    POSSIBLE_FILES.each do |opts|
      url = build_url(date + opts[0], opts[1])
      puts url
      if valid_url?(url)
        file_path = "#{file_base}.#{opts[1]}"
        open(file_path, 'wb') do |file|
          file << open(url).read
        end
        return file_path
      end
    end
    raise 'No file to download'
  end

  private

  def valid_url?(url)
    uri = URI.parse(url)
    req = Net::HTTP.new(uri.host, uri.port)
    res = req.request_head(uri.path)
    res.code == "200"
  end

  def build_url(date, file_ending)
    "http://www.fi.se/upload/50_Marknadsinfo/Blankning/Korta_positioner_#{date}.#{file_ending}"
  end
end

