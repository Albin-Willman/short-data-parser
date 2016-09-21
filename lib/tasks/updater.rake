require 'date'
require 'json'
require 'fileutils'
require 'pathname'
require 'set'

require_relative "../utilities/downloader.rb"
require_relative "../utilities/Uploader.rb"
require_relative "../utilities/parser.rb"
require_relative "../utilities/StockIndexBuilder.rb"
require_relative "../utilities/CompanyDataBuilder.rb"

XLS_PATH = 'tmp/data.xls'
namespace :fi do

  task :update_short_tracker_and_notify, :date do |t, args|
    Rake::Task['fi:update_short_tracker'].invoke(args[:date])
    `say "Updated short-tracker"`
  end

  task :intelligent_updater, :date do |t, args|
    date = valid_date?(args[:date]) ? Date.parse(args[:date]) : Date.today
    return if date.saturday? || date.sunday?
    Rake::Task['fi:update_short_tracker'].invoke(date)
  end

  task :update_short_tracker, :date do |t, args|
    puts "Starting update"
    Rake::Task['fi:try_download'].invoke(args[:date])
    Rake::Task['fi:parse_xls'].invoke
    Rake::Task['fi:upload_to_s3'].invoke
    puts 'Update completed'
  end

  task :try_download, :date do |t, args|
    downloaded = false
    until downloaded do
      begin
        Rake::Task['fi:download'].invoke(args[:date])
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
    puts "Downloading xls for #{date}"
    Downloader.new.run(XLS_PATH, date.to_s)
    puts 'Downloaded'
  end

  task :parse_xls => :environment do
    puts 'Start parsing XLS'
    XlsParser.new.run(XLS_PATH)
    puts 'Done parsing XLS'
  end

  task :upload_to_s3 => :environment do
    puts 'Start updating s3'
    uploader = Uploader.new

    uploader.run(StockIndexBuilder.new.run, 'tmp/api/v2/stocks.json')
    company_data_builder = CompanyDataBuilder.new
    Company.all.each do |c|
      puts "Building #{c.name}"
      if uploader.run(company_data_builder.run(c), "tmp/api/v2/stocks/#{c.key}.json")
        c.last_update = Date.today
        c.save
      else
        puts 'No update'
      end
    end
    puts 'Done updating s3'
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
end
