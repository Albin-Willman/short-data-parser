require 'date'
require 'json'
require 'fileutils'
require 'pathname'
require 'set'

require_relative "../utilities/downloader.rb"
require_relative "../utilities/Uploader.rb"
require_relative "../utilities/parser.rb"
require_relative "../utilities/StockIndexBuilder.rb"
require_relative "../utilities/ActorIndexBuilder.rb"
require_relative "../utilities/CompanyDataBuilder.rb"
require_relative "../utilities/ActorDataBuilder.rb"

XLS_PATH = 'tmp/data.xls'
API_PATH = 'api/v2'
namespace :fi do

  task :update_short_tracker_and_notify, :date do |t, args|
    Rake::Task['fi:update_short_tracker'].invoke(args[:date])
    `say "Updated short-tracker"`
  end

  task :intelligent_updater, :date do |t, args|
    date = valid_date?(args[:date]) ? Date.parse(args[:date]) : Date.today
    unless date.saturday? || date.sunday?
      Rake::Task['fi:update_short_tracker'].invoke(date)
    else
      puts '*** Skipping due to weekend ***'
    end
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

    uploader.run(StockIndexBuilder.new.run, "#{API_PATH}/stocks.json")
    upload_companies(uploader)
    uploader.run(ActorIndexBuilder.new.run, "#{API_PATH}/actors.json")
    upload_actors(uploader)

    puts 'Done updating s3'
  end

  def upload_companies(uploader)
    company_data_builder = CompanyDataBuilder.new
    Company.all.each do |c|
      puts "Building #{c.name}"
      if uploader.run(company_data_builder.run(c), "#{API_PATH}/stocks/#{c.key}.json")
        c.last_update = Date.today
        c.save
      else
        puts 'No update'
      end
    end
  end

  def upload_actors(uploader)
    company_data_builder = ActorDataBuilder.new
    Actor.all.each do |a|
      puts "Building actor: #{a.name}"
      if uploader.run(company_data_builder.run(a), "#{API_PATH}/actors/#{a.key}.json")
        a.last_update = Date.today
        a.save
      else
        puts 'No update'
      end
    end
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
