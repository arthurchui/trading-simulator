# frozen_string_literal: true

require 'csv'
require 'yquotes/yahoo'

class Importer

  def self.download_historical_data
    puts 'Importing ...'
    csv_contents = create_ticker_list
    i = 0
    csv_contents.each do |row|
      download_historical_stock_data row[0].split('|')[0]
      i += 1
      break if i > 10 # TODO: Figure out how to download all data in a way that doesn't over-tax Yahoo's API
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
    csv = YQuotes::Yahoo.new.get_csv(ticker, '2010-01-01', '2019-12-31', 'd')

    #noinspection RubyArgCount
    FileUtils.mkdir('imported') unless File.directory?('imported')

    file_path = "imported/#{ticker}.csv"

    CSV.open(file_path, 'w') do |out|
      csv.each do |row|
        out << row unless row.include? 'null'
      end
    end

    puts File.expand_path("Download historical data for #{ticker} to #{file_path}")
  end
end
