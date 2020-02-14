class BulkSimulator
  attr_reader :stop_loss_coefficient

  def initialize(stop_loss_coefficient)
    @stop_loss_coefficient = stop_loss_coefficient
  end

  def call
    stock_symbols.each do |symbol|
      Simulator.new(symbol, stop_loss_coefficient).call
    end
  end

  def stock_symbols
    @stock_symbols ||= Dir.glob("darvas/*.csv").map do |path|
      File.basename(path, ".csv")
    end
  end
end