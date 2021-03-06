# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  resource_id   :integer
#  resource_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  scopify

  AVAILABLE_ROLES = [ :admin, :team_leader ]
  unless !!UberZeit.config.disable_activities
    AVAILABLE_ROLES << :accountant
  end

  RESOURCABLE_ROLES = [ :team_leader ]

  def to_s
    name
  end
end

