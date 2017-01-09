# == Schema Information
#
# Table name: time_spans
#
#  id                             :integer          not null, primary key
#  date                           :date
#  duration                       :integer
#  duration_in_work_days          :float
#  duration_bonus                 :integer
#  user_id                        :integer
#  time_type_id                   :integer
#  time_spanable_id               :integer
#  time_spanable_type             :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  credited_duration              :integer
#  credited_duration_in_work_days :float
#

require_relative 'concerns/dated'

class TimeSpan < ActiveRecord::Base
  include Dated

  belongs_to :user
  belongs_to :time_type
  belongs_to :time_spanable, polymorphic: true

  attr_accessible :date, :duration, :duration_bonus, :duration_days

  validates_presence_of :date,
                        :duration, :duration_in_work_days,
                        :credited_duration, :credited_duration_in_work_days,
                        :user_id, :time_type_id, :time_spanable_id, :time_spanable_type

  scope_date :date

  scope :for_team, ->(team) { where(user_id: User.in_teams(team)) }
  scope :for_user, ->(user) { where(user_id: user) }

  scope :exclude_vacation_adjustments, -> do
    joins(:time_type)
      .where('NOT (time_spanable_type = ? AND time_types.is_vacation = ?)',
             Adjustment.to_s,
             true)
  end

  scope :absences_with_adjustments, -> do
    where(time_spanable_type: %w[Absence Adjustment])
      .exclude_vacation_adjustments
  end

  scope :absences, -> do
    where(time_spanable_type: Absence.to_s)
  end

  scope :working_time, -> do
    joins(:time_type)
      .where(time_types: {exclude_from_calculation: false})
      .exclude_vacation_adjustments
  end

  scope :effective_working_time, -> do
    where(time_spanable_type: TimeEntry.to_s)
      .joins(:time_type)
      .where(time_types: {is_work: true})
  end

  scope :adjustments, -> do
    joins(:time_type)
      .where(time_spanable_type: Adjustment.to_s)
      .exclude_vacation_adjustments
  end

  scope :exclude_adjustments, -> do
    where.not(time_spanable_type: Adjustment.to_s)
  end

  scope :vacation_adjustments, -> do
    joins(:time_type)
      .where(time_types: {is_vacation: true})
      .where(time_spanable_type: Adjustment.to_s)
  end

  scope :vacation, -> do
    joins(:time_type)
      .where(time_types: {is_vacation: true})
      .exclude_vacation_adjustments
  end

  def self.duration_in_work_day_sum_per_user_and_time_type
    group(:user_id).group(:time_type_id).sum(:duration_in_work_days)
  end

  def self.duration_in_work_day_sum_per_time_type
    group(:time_type_id).sum(:duration_in_work_days)
  end

  def self.duration_sum
    sum(:duration)
  end

  def self.duration_sum_per_time_type
    group(:time_type_id).sum(:duration)
  end

  def self.credited_duration_sum
    sum(:credited_duration)
  end

  def self.credited_duration_sum_per_time_type
    group(:time_type_id).sum(:credited_duration)
  end

  def self.credited_duration_in_work_days_sum
    sum(:credited_duration_in_work_days)
  end

  def self.credited_duration_in_work_days_sum_per_time_type
    group(:time_type_id).sum(:credited_duration_in_work_days)
  end

  def self.credited_duration_in_work_day_sum_per_user_and_time_type
    group(:user_id).group(:time_type_id).sum(:credited_duration_in_work_days)
  end

  def duration=(value)
    write_attribute :duration_in_work_days, value.to_work_days
    super
  end

  def duration_in_work_days=(value)
    write_attribute :duration, value.work_days
    super
  end

  def credited_duration=(value)
    write_attribute :credited_duration_in_work_days, value.to_work_days
    super
  end

  def credited_duration_in_work_days=(value)
    write_attribute :credited_duration, value.work_days
    super
  end

end
