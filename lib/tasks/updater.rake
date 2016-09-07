require 'date'
require 'json'
require 'fileutils'
require 'pathname'
require 'set'

require_relative "../utilities/downloader.rb"
require_relative "../utilities/Uploader.rb"
require_relative "../utilities/parser.rb"
require_relative "../utilities/DateList.rb"
require_relative "../utilities/CompanyChecker.rb"

XLS_PATH = 'tmp/data.xls'
DATA_PATH = 'data/dist/api/'
DATA_FILE_NAME = 'data.json'
STOCKS_FOLDER = '/stocks'
namespace :fi do

  task :update_short_tracker_and_notify do
    Rake::Task['fi:update_short_tracker'].invoke
    `say "Updated short-tracker"`
  end

  task :update_short_tracker => :environment do
    Rake::Task['fi:try_download'].invoke
    Rake::Task['fi:parse_xls'].invoke
    Rake::Task['fi:get_stock_data'].invoke
    Rake::Task['fi:upload_to_s3'].invoke
  end

  task :try_download do
    downloaded = false
    until downloaded do
      begin
        Rake::Task['fi:download'].invoke
        downloaded = true
      rescue
        puts 'Failed waiting 30 sec'
        sleep 30
      ensure
        Rake::Task['fi:download'].reenable
      end
    end
  end


  task :download, :date do |t, args|
    date = valid_date?(args[:date]) ? args[:date] : Date.today
    data_path = Downloader.new.run(XLS_PATH, date.to_s)
    puts `ls tmp/`
  end

  task :parse_xls => :environment do
    puts `ls tmp/`
    FileUtils::mkdir_p DATA_PATH
    data = XlsParser.new.run(XLS_PATH)
    get_companies.each do |company, values|
      next unless data[company]
      data[company]['nn_id'] = values['nn_id']
    end
    File.open(data_file_path,"w") do |f|
      f.write({
        companies: data,
        updated: Date.today.to_s
      }.to_json)
    end
  end

  task :get_stock_data => :environment do
    FileUtils::mkdir_p DATA_PATH + STOCKS_FOLDER
    company_checker = CompanyChecker.new
    get_companies.each do |company, data|
      company_checker.check_company(company, data, data_file_path)
    end
  end

  task :upload_to_s3 => :environment do
    Uploader.new.run
  end

  def valid_date?(date)
    return true if date.is_a? Date
    begin
      Date.parse(date)
      return true
    rescue
      return false
    end
  end

  def get_companies
    return { 'companies' => [] } unless File.file?(data_file_path)
    JSON.parse(File.read(data_file_path))['companies']
  end

  def data_file_path
    DATA_PATH + DATA_FILE_NAME
  end
end