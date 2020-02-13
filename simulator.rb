#!/usr/bin/env ruby

require 'csv'
require './position.rb'

class Simulator

  attr_accessor :open_position
  attr_reader :closed_positions, :stop_loss_coefficient

  def initialize(stock, stop_loss_coefficient)
    @closed_positions = []
    @open_position = nil
    @stop_loss_coefficient = stop_loss_coefficient
    @stock = stock
  end

  def call
    should_buy = false
    pricing_data.each do |day|
      current_date = day['Date']
      if open_position
        if open_position.sell?(day['Low'].to_f)
          close_open_position(current_date)
        else
          update_stop_loss_price(day['Close'].to_f)
        end
      elsif should_buy
        open_position!(current_date, day['Open'].to_f)
      end
      should_buy = buy_signal?(current_date)
    end

    close_open_position(pricing_data[-1]['Date'], pricing_data[-1]['Close']) if open_position
    output_trade_history
  end

  private

  def update_stop_loss_price(current_close)
    open_position.stop_loss_price = current_close * stop_loss_coefficient
  end

  def buy_signal?(current_date)
    buy_dates.any? { |buy_date| buy_date['date'] == current_date }
  end

  def open_position!(current_date, open_price)
    @open_position = Position.new(current_date, open_price, open_price * stop_loss_coefficient)
  end

  def close_open_position(close_date, close_price = open_position.stop_loss_price)
    open_position.close!(close_date, close_price)
    closed_positions << open_position
    @open_position = nil
  end

  def buy_dates
    @buy_dates ||= CSV.read('data/nflx_buy_dates.csv', headers: true)
  end

  def pricing_data
    @pricing_data ||= CSV.read('data/NFLX.csv', headers: true)
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
