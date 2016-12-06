class Date
  def to_range
    (self..self)
  end

  def current
    Time.current.to_date
  end
end
