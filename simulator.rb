#!/usr/bin/env ruby

require 'csv'
require './position.rb'

class Simulator

  attr_reader :closed_positions, :stop_loss_coefficient

  def initialize(stock, stop_loss_coefficient)
    @closed_positions = []
    @stop_loss_coefficient = stop_loss_coefficient
    @stock = stock
  end

  def call()
    open_position = nil
    pricing_data.each do |day|
      current_date = day['Date']
      if open_position
        if day['Low'].to_f < open_position.stop_loss_price
          open_position.close!(current_date)
          closed_positions << open_position
          open_position = nil
        else
          open_position.update_stop_loss_price(day['Close'].to_f * stop_loss_coefficient)
        end
      elsif buy_dates.any? { |buy_date| buy_date['date'] == current_date }
        open_position = Position.new(current_date, day['Open'], day['Open'].to_f * stop_loss_coefficient)
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
    CSV.open('data/nflx_trade_history.csv', 'wb') do |csv|
      csv << %w[buy_date buy_price sell_date sell_price]
      closed_positions.each do |position|
        csv << [position.open_date, position.open_price, position.close_date,
                position.close_price]
      end
    end
  end
end
