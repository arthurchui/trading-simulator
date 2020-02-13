# frozen_string_literal: true

require 'csv'
require 'yquotes/yahoo'

class Importer

  def self.download_historical_data
    puts 'Importing ...'
    csv_contents = create_ticker_list
    csv_contents.each_with_index do |row, i|
      begin
        ticker = row[0].split('|')[0]
        download_historical_stock_data(ticker)
      rescue 
        puts "Unable to import ticker: #{ticker}"
      end
    end
  end

  private

  def self.create_ticker_list
    csv_contents = CSV.read('nasdaqlisted.txt')
    csv_contents.shift
    csv_contents.pop
    csv_contents
  end

  def self.download_historical_stock_data(ticker)
    file_path = "imported/#{ticker}.csv"
    return if File.exist?(file_path)

    csv = YQuotes::Yahoo.new.get_csv(ticker, '2010-01-01', '2019-12-31', 'd')

    #noinspection RubyArgCount
    FileUtils.mkdir_p('imported') unless File.directory?('imported')


    CSV.open(file_path, 'w') do |out|
      csv.each do |row|
        out << row unless row.include? 'null'
      end
    end

    puts File.expand_path("Download historical data for #{ticker} to #{file_path}")
  end
end
