require 'uber_zeit/bonus_calculators/dummy'
require 'uber_zeit/bonus_calculators/base_nightly_window'
require 'uber_zeit/bonus_calculators/ftw_nightly'

module UberZeit::BonusCalculators

  @@available_calculators = HashWithIndifferentAccess.new
  mattr_reader :available_calculators

  def self.register(identifier, calculator)
    @@available_calculators[identifier] = calculator
  end

  def self.use(identifier, params)
    return UberZeit::BonusCalculators::Dummy.new if identifier.blank?
    @@available_calculators[identifier].new(params)
  end

end
