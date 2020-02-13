# #!/usr/bin/env ruby

# Thor reference: http://whatisthor.com/
require "thor"

class Trader < Thor
  desc "import", "download the historical EOD of NASDAQ"
  def import
    puts "Importing ..."
  end

  desc "simulate", "simulate trades with the historical data"
  option :start_date, type: :string, desc: "yyyy-mm-dd"
  option :end_date, type: :string, desc: "yyyy-mm-dd"
  option :stock, type: :string
  def simulate
    puts "Simulating ..."
  end
end

Trader.start(ARGV)
