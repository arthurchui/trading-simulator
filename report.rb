class Report

  attr_reader :position_size

  def initialize(position_size)
    @position_size = position_size
  end

  def call
    CSV.open('report/all.csv', 'wb') do |csv|
      csv << %w[stock positions_count profit_loss]
      simulated_result_paths.each do |path|
        positions = CSV.read(path, headers: true)

        profit_loss = calculate_profit_loss(positions)

        csv << [
          File.basename(path, '.csv'),
          positions.count,
          profit_loss
        ]
      end
    end
  end

  private

  def calculate_profit_loss(positions)
    position_profit_loss = positions.map do |position|
      share_count = position_size / position['buy_price'].to_f
      profit_loss_per_share = position['sell_price'].to_f - position['buy_price'].to_f
      share_count * profit_loss_per_share
    end
    position_profit_loss.sum
  end

  def simulated_result_paths
    Dir.glob('simulated/*.csv')
  end
end
