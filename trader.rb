# #!/usr/bin/env ruby

# Thor reference: http://whatisthor.com/
require 'thor'
require_relative 'importer'

class Trader < Thor
  desc 'import', 'download the historical EOD of NASDAQ'
  def import
    Importer.download_historical_data
  end

  desc 'simulate', 'simulate trades with the historical data'
  option :start_date, type: :string, desc: 'yyyy-mm-dd'
  option :end_date, type: :string, desc: 'yyyy-mm-dd'
  option :stock, type: :string
  def simulate
    puts 'Simulating ...'
  end
end

Trader.start(ARGV)
