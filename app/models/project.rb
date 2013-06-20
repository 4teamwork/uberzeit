class Project < ActiveRecord::Base
  belongs_to :customer, primary_key: :id

  attr_accessible :name, :customer, :customer_id

  validates_presence_of :customer, :name

  scope :by_customer, ->(user) { where(customer_id: user)}
end