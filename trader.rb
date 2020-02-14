# #!/usr/bin/env ruby

# Thor reference: http://whatisthor.com/
require 'thor'
require_relative 'importer'
require './bulk_simulator'
require './position'
require './simulator'
require "csv"
require_relative "darvas"

class Trader < Thor
  desc 'import', 'download the historical EOD of NASDAQ'
  def import
    Importer.download_historical_data
  end

  desc 'simulate', 'simulate trades with the historical data'
  option :stop_loss, type: :numeric, desc: 'expressed as a ratio (e.g. 0.9 -> sell at 90% the value)'
  def simulate
    puts 'Simulating ...'
    stop_loss = options[:stop_loss] || 0.9
    BulkSimulator.new(stop_loss).call
  end

  desc 'darvas', 'darvas'
  def darvas
    FileUtils.rm_rf('darvas')
    FileUtils.mkdir_p('darvas')

    puts "Darvas ..."
    Dir.glob("imported/*.csv").each do |file|
      puts "Analyzing #{file}"
      begin
        csv = CSV.read(file, headers: true)
        dates = Darvas.new(csv).perform
        next if dates.empty?
        filename = Pathname.new(file).basename.to_s
        File.open("darvas/#{filename}", "w") { |file| file.write(dates.join("\n")) }
      rescue => e
        puts e
      end
    end
  end
end

Trader.start(ARGV)
