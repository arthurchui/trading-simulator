# #!/usr/bin/env ruby

# Thor reference: http://whatisthor.com/
require 'thor'
require_relative 'importer'
require './simulator'

class Trader < Thor
  desc 'import', 'download the historical EOD of NASDAQ'
  def import
    Importer.download_historical_data
  end

  desc 'simulate', 'simulate trades with the historical data'
  option :stop_loss, type: :numeric, desc: 'expressed as a ratio (e.g. 0.9 -> sell at 90% the value)'
  option :stock, type: :string, required: true
  def simulate
    puts 'Simulating ...'
    stop_loss = options[:stop_loss] || 0.9
    Simulator.new(options[:stock], stop_loss).call
  end
end

Trader.start(ARGV)
