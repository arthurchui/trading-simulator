class Report
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
      position['sell_price'].to_f - position['buy_price'].to_f
    end
    position_profit_loss.sum
  end

  def simulated_result_paths
    Dir.glob('simulated/*.csv')
  end
end
