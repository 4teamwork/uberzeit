class UberZeit::BonusCalculators::FtwNightly
  include UberZeit::BonusCalculators::BaseNightlyWindow

  FACTOR = 0.25
  ACTIVE = { ends: 7, starts: 24 }
  DESCRIPTION = 'Calculates the bonus for planned work during nightly work'.freeze
  NAME ='4teamwork Nightly Hours Bonus'.freeze
end

class UberZeit::BonusCalculators::FtwSunday
  include UberZeit::BonusCalculators::BaseNightlyWindow

  FACTOR = 0.5
  ACTIVE = { ends: 0, starts: 24 }
  DESCRIPTION = 'Calculates the bonus for planned work during sundays'.freeze
  NAME ='4teamwork Sunday Hours Bonus'.freeze
end
