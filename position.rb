class Position

  attr_reader :open_date, :open_price, :close_date, :close_price, :stop_loss_price

  def initialize(open_date, open_price, stop_loss_price)
    @open_date = open_date
    @open_price = open_price
    @stop_loss_price = stop_loss_price
  end

  def sell?(current_price)
    current_price < stop_loss_price
  end

  def close!(close_date, close_price = stop_loss_price)
    @close_date = close_date
    @close_price = close_price
  end

  def open?
    !close_date
  end

  def stop_loss_price=(new_stop_loss_price)
    @stop_loss_price = [stop_loss_price, new_stop_loss_price].max
  end

  def to_s
    "#{open_date}, #{open_price}, #{close_date}, #{close_price}"
  end
end
