require "csv"
require 'pry'
class Darvas
  attr_reader :stock_csv
  SPIKE_PERCENTAGE = 10
  OBSERVATION_PERIOD = 30
  BREAKOUT_PERCENTAGE = 1.1

  def initialize(stock_csv, start_date: Date.parse("2010-01-01"))
    @stock_csv = stock_csv.select do |row|
      Date.parse(row[0]) >= start_date
    end
  end

  def perform
    spike_indexes = volume_spike_indexes(SPIKE_PERCENTAGE)
    dates = []
    spike_indexes.each do |spike_index|
      max, min = get_box_boundaries(spike_index, OBSERVATION_PERIOD)
      next if max.nil?
      date = monitor(BREAKOUT_PERCENTAGE, spike_index, max, min)
      dates << date if date
    end
    dates.uniq.sort
  end

  # Takes a spike percentage and returns all the spikes
  def volume_spike_indexes(spike_percent)
    previous_vol = @stock_csv[0][-1].to_i
    indexes = []
    @stock_csv.each.with_index do |row, i|
      indexes << i if previous_vol * spike_percent < row[6].to_i
      previous_vol = row[6].to_i
    end
    indexes
  end

  # returns high and low boundaries
  def get_box_boundaries(spike_index, observation_period)
    if spike_index > observation_period
      days = @stock_csv[spike_index - observation_period...spike_index]
      eod_values = days.map { |row| row[5] }
      [eod_values.max.to_f, eod_values.min.to_f]
    end
  end

  def monitor(breakout_percentage, spike_index, max, min)
    @stock_csv[spike_index..-1].each do |row|
      return row[0] if row[5].to_f > max * breakout_percentage
      break if row[5].to_f < min
    end
    nil
  end
end


# Output CSV with header: date, body: buy dates (day after breakout)