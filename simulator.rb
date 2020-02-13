#!/usr/bin/env ruby

require 'csv'

class Simulator

  def call
    # TODO: Process data
    # for each day
    #    do we have an open position?
    #      do we need to sell?
    #    (else) do we intend to buy?
    #      get open price
    #      calculate stop loss
    #      record
    output_trade_history
  end

  def buy_dates
    @buy_dates ||= CSV.read('data/tsla_buy_dates.csv', headers: true)
  end

  def pricing_data
    @pricing_data ||= CSV.read('data/tsla_pricing_data.csv', headers: true)
  end

  def output_trade_history
    puts "output history"
    # TODO
  end

end

Simulator.new.call
