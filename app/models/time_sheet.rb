class TimeSheet
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def overtime(date_or_range)
    bonus(date_or_range) + working_time_total(date_or_range) - planned_working_time(date_or_range)
  end

  def bonus(date_or_range, time_types = TimeType.all)
    user.time_spans.with_date(date_or_range).where(time_type_id: time_types).sum(:duration_bonus)
  end

  def planned_working_time(date_or_range)
    range = date_or_range.to_range.to_date_range
    FetchPlannedWorkingTime.new(user, range).total
  end

  def redeemed_vacation(range)
    user.time_spans.with_date(range).vacation.credited_duration_in_work_days_sum
  end

  def remaining_vacation(year)
    total_redeemable_vacation(year) - redeemed_vacation(UberZeit.year_as_range(year))
  end

  def remaining_vacation_per(date)
    first_day_of_year = date.beginning_of_year
    total_redeemable_vacation(date.year) - redeemed_vacation(first_day_of_year..date)
  end

  def total_redeemable_vacation(year)
    vacation = CalculateTotalRedeemableVacation.new(user, year)
    vacation.total_redeemable_for_year.to_work_days
  end

  def duration_of_timers(date_or_range)
    range = date_or_range.to_range.to_date_range
    timers_in_range = user.time_entries.timers_only.select { |timer| range.intersects_with_duration?(timer.range) }
    timers_in_range.inject(0) { |sum,timer| sum + timer.duration(range) }
  end

  def working_time_total(date_or_range)
    user.time_spans.with_date(date_or_range).working_time.credited_duration_sum
  end

  def working_time_without_adjustments_total(date_or_range)
    user.time_spans.with_date(date_or_range).working_time.exclude_adjustments.credited_duration_sum
  end

  def working_time_by_type(date_or_range)
    user.time_spans.with_date(date_or_range).working_time.credited_duration_sum_per_time_type
  end

  def effective_working_time_total(date_or_range)
    user.time_spans.with_date(date_or_range).effective_working_time.credited_duration_sum
  end

  def effective_working_time_by_type(date_or_range)
    user.time_spans.with_date(date_or_range).effective_working_time.credited_duration_sum_per_time_type
  end

  def absences_total(date_or_range)
    user.time_spans.with_date(date_or_range).absences.credited_duration_sum
  end

  def absences_by_type(date_or_range)
    user.time_spans.with_date(date_or_range).absences.credited_duration_sum_per_time_type
  end

  def adjustments_total(date_or_range)
    user.time_spans.with_date(date_or_range).adjustments.credited_duration_sum
  end

  def adjustments_by_type(date_or_range)
    user.time_spans.with_date(date_or_range).adjustments.credited_duration_sum_per_time_type
  end


end
