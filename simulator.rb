#!/usr/bin/env ruby

require 'csv'
require './position.rb'

class Simulator

  def call
    closed_positions = []
    open_position = nil
    pricing_data.each do |day|
      current_date = day['Date']
      if open_position
        puts "#{day['Low']}, #{open_position.stop_loss_price}"
        if day['Low'].to_f < open_position.stop_loss_price
          open_position.close!(current_date)
          closed_positions << open_position
          open_position = nil
        else
          # TODO: update stop loss
        end
      elsif buy_dates.any? { |buy_date| buy_date['date'] == current_date }
        open_position = Position.new(current_date, day['Open'], day['Open'].to_f * 0.99)  # TODO roundoff?
      end
    end

    if open_position
      open_position.close!(pricing_data[-1]['Date'], pricing_data[-1]['Close'])
      closed_positions << open_position
    end

    output_trade_history
  end

  def buy_dates
    @buy_dates ||= CSV.read('data/nflx_buy_dates.csv', headers: true)
  end

  def pricing_data
    @pricing_data ||= CSV.read('data/nflx_pricing_data.csv', headers: true)
  end

  def output_trade_history
    puts "output history"
    # TODO
  end

end

Simulator.new.call
