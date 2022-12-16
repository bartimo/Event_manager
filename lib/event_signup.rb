class Event_Signup
  attr_reader :hours, :days_of_week

  def initialize()
    @hours = {}
    @days_of_week= {}
  end

  def append_time(time)
    append_time_to_hours(time.hour)
    append_time_to_days(time.wday)
  end

  private

  def append_time_to_hours(time)
    @hours.has_key?(time) ? @hours[time] += 1 : @hours[time] = 1
  end

  def append_time_to_days(day)
    @days_of_week.has_key?(day) ? @days_of_week[day] += 1 : @days_of_week[day] = 1
  end

end