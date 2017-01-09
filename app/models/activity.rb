# == Schema Information
#
# Table name: activities
#
#  id                :integer          not null, primary key
#  activity_type_id  :integer
#  user_id           :integer
#  date              :date
#  duration          :integer
#  description       :text
#  customer_id       :integer
#  project_id        :integer
#  redmine_ticket_id :integer
#  otrs_ticket_id    :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  billable          :boolean          default(FALSE), not null
#  reviewed          :boolean          default(FALSE), not null
#  billed            :boolean          default(FALSE), not null
#

require_relative 'concerns/dated'

class Activity < ActiveRecord::Base
  include Dated
  include CustomerAssignable

  acts_as_paranoid

  belongs_to :activity_type, with_deleted: true
  belongs_to :project, with_deleted: true
  belongs_to :user, with_deleted: true

  attr_accessible :customer_id, :date, :description, :duration, :otrs_ticket_id, :project_id, :redmine_ticket_id, :activity_type_id, :user_id, :billable, :billed, :reviewed

  validates_presence_of :user, :activity_type, :date, :duration
  validates_numericality_of :duration, greater_than: 0

  scope :ordered, -> { order(:created_at) }
  scope :by_user, ->(user) { where(user_id: user)}
  scope :by_redmine_ticket, ->(redmine_ticket_id) { where(redmine_ticket_id: redmine_ticket_id) }
  scope :by_otrs_ticket, ->(otrs_ticket_id) { where(otrs_ticket_id: otrs_ticket_id) }

  scope_date :date

  def billable?
    !!billable
  end

  def reviewed?
    !!reviewed
  end

  def billed?
    !!billed
  end

  def self.latest
    order(updated_at: :desc, id: :desc).first
  end

  def self.sum_by_activity_type
    summarize joins(:activity_type)
               .select('activity_types.name, activities.billable, sum(activities.duration) as duration')
               .where(reviewed: true)
               .group('activity_types.name, billable')
               .reorder('activity_types.name')
  end

  def self.sum_by_customer
    summarize joins(:customer)
               .select('customers.name, activities.billable, sum(activities.duration) as duration')
               .where(reviewed: true)
               .group('customers.name, billable')
               .reorder('customers.name')
  end

  def self.sum_by_project
    summarize joins(:project)
               .joins(:customer)
               .select('projects.name, activities.billable, sum(activities.duration) as duration')
               .where(reviewed: true)
               .group('customers.name, projects.name, billable')
               .reorder('projects.name')
  end


  private
  def self.summarize(records)
    sums = {}
    records.each do |record|
      billable_type = record.billable? ? :billable : :not_billable
      [billable_type, :duration].each do |group|
        sums[record[:name]] ||= {}
        sums[record[:name]][group] ||= 0
        sums[record[:name]][group] += record.duration
      end
    end
    sums
  end
end
