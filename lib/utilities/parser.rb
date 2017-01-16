require "simple-spreadsheet"
require 'date'

class XlsParser

  POSSIBLE_FORMATS = ['xls', 'xlsx']
  def run(file_path, = false)
    @file_path = file_path
    @companies = {}
    @actors = {}
    @found_lines = 0
     =
    parse_file
    delete_file
    @companies
  end

  private

  def delete_file
    FileUtils.rm(@file_path)
  end

  def parse_file
    file.first_row.upto(file.last_row) do |line|
      parse_line(line)
      return if @fast && @found_lines > 9
    end
  end

  def parse_line(line)
    return true unless valid_date?(file.cell(line, 1))
    actor = file.cell(line, 2)
    return true if !actor || actor.gsub(/[^0-9a-z]/i, '') == 'IngapublikapositionerpubliceradesNopublicpositionswerepublished'
    if Position.find_by(line_hash: line_hash(line))
      @found_lines += 1
      return
    end
    company_name = file.cell(line, 3)

    company = find_company_key(company_name)

    amount = file.cell(line, 5)
    amount = amount.tr(',', '.').to_f if amount.is_a?(String)
    amount = 0 if amount < 0.5
    date = Date.parse(file.cell(line, 6).to_s)

    actor_key = actor.split(" ").first.downcase

    Position.create(
      company: company(company, company_name),
      actor: actor(actor_key, actor),
      date: date,
      value: amount,
      line_hash: line_hash(line)
    )
    true
  end

  def line_hash(line)
    "
      #{file.cell(line, 1)}
      #{file.cell(line, 2)}
      #{file.cell(line, 3)}
      #{file.cell(line, 4)}
      #{file.cell(line, 5)}
      #{file.cell(line, 6)}
    ".gsub(/[^0-9a-z]/i, '')
  end

  def find_company_key(company_name)
    company = company_name.split(" ").first.downcase
    case company
    when 'elektrolux'
      return 'electrolux'
    when 'telefonaktiebolaget'
      return 'ericsson'
    when 'swedish'
      return company + company_name.split(" ")[1].downcase
    when 'h'
      return 'h&m'
    when 'billerudkorsnäs', 'billerudkorsnas'
      return 'billerud'
    when 'cdon'
      return 'qliro'
    when 'gränges'
      return 'granges'
    when 'alfa'
      return 'alfa-laval'
    when 'fingerprints'
      return 'fingerprint'
    else
      return company
    end
  end

  def actor(key, actor = nil)
    @actors[key] = Actor.find_by(key: key) unless @actors[key]
    @actors[key] = Actor.create(key: key, name: actor) unless @actors[key]
    @actors[key]
  end

  def company(key, name = nil)
    @companies[key] = Company.find_by(key: key) unless @companies[key]
    @companies[key] = Company.create(key: key, name: name) unless @companies[key]
    @companies[key]
  end

  def file
    @file ||= read_file
  end

  def read_file
    POSSIBLE_FORMATS.each do |form|
      complete_path = "#{@file_path}.#{form}"
      next unless File.file?(complete_path)
      @file_path = complete_path
      return SimpleSpreadsheet::Workbook.read(@file_path)
    end
    throw "No file to parse"
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
