require 'open-uri'
require "net/http"

POSSIBLE_FILES = [
  'xlsx',
  'xls'
]

BASE_URL = 'http://fi.se';

class Downloader

  def run(file_base, date)
    url = find_url(date)
    POSSIBLE_FILES.each do |ending|
      puts url
      next unless valid_url?(url, ending)

      file_path = "#{file_base}.#{ending}"
      open(file_path, 'wb') do |file|
        file << open(url).read
      end
      return file_path
    end
    raise 'No file to download'
  end

  private

  def find_url(date)
    link = Nokogiri::HTML(open("#{BASE_URL}/sv/vara-register/blankning/")).at(link_text(date))
    return unless link
    BASE_URL + link['href']
  end

  def link_text(date)
    "a:contains(\"Publicerade blankningar #{date} (i excel-format)\")"
  end

  def valid_url?(url, ending)
    return false unless url
    url.end_with?(ending)
  end
end

